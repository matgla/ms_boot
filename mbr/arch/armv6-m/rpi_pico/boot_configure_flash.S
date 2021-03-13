// This file is part of MSBOOT project.
// Copyright (C) 2021 Mateusz Stadnik
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

#include "hardware/regs/addressmap.h"
#include "hardware/regs/ssi.h"
#include "hardware/regs/pads_qspi.h" 

#ifndef SPI_CLKDIV
#define SPI_CLKDIV 2
#endif 

#if SPI_CLKDIV & 1 
#error SPI_CLKDIV must be even 
#endif 

// read data fast quad io 
#define CMD_READ            0xeb 
#define MODE_CONTINOUS_READ 0xa0 
#define ADDR_L              8 
#define WAIT_CYCLES         4

#define CMD_WRITE_ENABLE                0x06
#define CMD_READ_STATUS_REGISTER_1      0x05 
#define CMD_READ_STATUS_REGISTER_2      0x35 
#define CMD_WRITE_STATUS                0x01 
#define SREG_DATA                       0x02 // enable qspi mode

// GPIO configuration 
#define GPIO_PAD_8MA_DRIVE  0x02

.syntax unified
.cpu cortex-m0plus
.thumb 

pads_qspi_reg .req r7 
ssi_reg .req r6

#define PAD_OPTIONS_8MA_NO_SLEWFAST_LIMIT ( \
    GPIO_PAD_8MA_DRIVE << PADS_QSPI_GPIO_QSPI_SCLK_DRIVE_LSB | \
    PADS_QSPI_GPIO_QSPI_SCLK_SLEWFAST_BITS)

#define SPI_CRTL0_TXRX_CONFIG \
    (7 << SSI_CTRLR0_DFS_32_LSB) | \
    (SSI_CTRLR0_TMOD_VALUE_TX_AND_RX << SSI_CTRLR0_TMOD_LSB)

#define SSI_CTRLR0_ENTER_XIP \
    ( SSI_CTRLR0_SPI_FRF_VALUE_QUAD << SSI_CTRLR0_SPI_FRF_LSB) | \
    ( 31 << SSI_CTRLR0_DFS_32_LSB)                             | \
    ( SSI_CTRLR0_TMOD_VALUE_EEPROM_READ << SSI_CTRLR0_TMOD_LSB) 

#define SPI_CTRLR0_ENTER_XIP \
    (ADDR_L << SSI_SPI_CTRLR0_ADDR_L_LSB) | \
    (WAIT_CYCLES << SSI_SPI_CTRLR0_WAIT_CYCLES_LSB) | \
    (SSI_SPI_CTRLR0_INST_L_VALUE_8B << SSI_SPI_CTRLR0_INST_L_LSB) | \
    (SSI_SPI_CTRLR0_TRANS_TYPE_VALUE_1C2A << SSI_SPI_CTRLR0_TRANS_TYPE_LSB)

#define SPI_CTRLR0_XIP \
    (MODE_CONTINOUS_READ << SSI_SPI_CTRLR0_XIP_CMD_LSB) | \
    (ADDR_L << SSI_SPI_CTRLR0_ADDR_L_LSB) | \
    (WAIT_CYCLES << SSI_SPI_CTRLR0_WAIT_CYCLES_LSB) | \
    (SSI_SPI_CTRLR0_INST_L_VALUE_NONE << SSI_SPI_CTRLR0_INST_L_LSB) | \
    (SSI_SPI_CTRLR0_TRANS_TYPE_VALUE_2C2A << SSI_SPI_CTRLR0_TRANS_TYPE_LSB) 

.section .text 
.global _stage2_boot
.type _stage2_boot,%function 
pad_configuration:
set_sclk_pad_current:
    ldr pads_qspi_reg, =PADS_QSPI_BASE
    ldr r0, =PAD_OPTIONS_8MA_NO_SLEWFAST_LIMIT
    str r0, [pads_qspi_reg, #PADS_QSPI_GPIO_QSPI_SCLK_OFFSET]
disable_schmitt:
    ldr r0, [pads_qspi_reg, #PADS_QSPI_GPIO_QSPI_SD0_OFFSET] 
    movs r1, #PADS_QSPI_GPIO_QSPI_SD0_SCHMITT_BITS
    bics r0, r1 // Clear SHMITT bits in QSPI SD 
    str r0, [pads_qspi_reg, #PADS_QSPI_GPIO_QSPI_SD0_OFFSET]
    str r0, [pads_qspi_reg, #PADS_QSPI_GPIO_QSPI_SD1_OFFSET]
    str r0, [pads_qspi_reg, #PADS_QSPI_GPIO_QSPI_SD2_OFFSET]
    str r0, [pads_qspi_reg, #PADS_QSPI_GPIO_QSPI_SD3_OFFSET]
configure_ssi_interface:
    ldr ssi_reg, =XIP_SSI_BASE

    // Disable SSI to perform configuration 
    movs r1, #0 
    str r1, [ssi_reg, #SSI_SSIENR_OFFSET]

    // set baudrate 
    movs r1, #SPI_CLKDIV
    str r1, [ssi_reg, #SSI_BAUDR_OFFSET]

    movs r1, #1 
    movs r2, #SSI_RX_SAMPLE_DLY_OFFSET 
    str r1, [ssi_reg, r2]

program_flash_status_register:
    ldr r1, =(SPI_CRTL0_TXRX_CONFIG)
    str r1, [ssi_reg, #SSI_CTRLR0_OFFSET]

    // enable SSI
    movs r3, #1 
    str r3, [ssi_reg, #SSI_SSIENR_OFFSET]

    movs r0, #CMD_READ_STATUS_REGISTER_2
    bl read_flash_status_register
    movs r2, SREG_DATA 
    cmp r0, r2 // is status register correct ? 
    beq skip_status_register_programming

    movs r1, #CMD_WRITE_ENABLE 
    str r1, [ssi_reg, #SSI_DR0_OFFSET]

    bl wait_ssi_ready
    ldr r1, [ssi_reg, #SSI_DR0_OFFSET] 

    // write status 
    movs r1, #CMD_WRITE_STATUS 
    str r1, [ssi_reg, #SSI_DR0_OFFSET]
    movs r0, #0 
    str r0, [ssi_reg, #SSI_DR0_OFFSET]
    str r2, [ssi_reg, #SSI_DR0_OFFSET] 
    
    bl wait_ssi_ready
    ldr r1, [ssi_reg, #SSI_DR0_OFFSET]
    ldr r1, [ssi_reg, #SSI_DR0_OFFSET]
    ldr r1, [ssi_reg, #SSI_DR0_OFFSET]

poll_status_register:
    movs r0, #CMD_READ_STATUS_REGISTER_1 
    bl read_flash_status_register 
    movs r1, #1
    tst r0, r1
    bne poll_status_register 

skip_status_register_programming:
    movs r1, #0 
    str r1, [ssi_reg, #SSI_SSIENR_OFFSET]

dummy_read: 
    ldr r1, =(SSI_CTRLR0_ENTER_XIP)
    str r1, [ssi_reg, #SSI_CTRLR0_OFFSET]
    movs r1, #0x0 
    str r1, [ssi_reg, #SSI_CTRLR1_OFFSET] 

enter_xip: 
    ldr r1, =(SPI_CTRLR0_ENTER_XIP)
    ldr r0, =(XIP_SSI_BASE + SSI_SPI_CTRLR0_OFFSET) 
    str r1, [r0] 

    movs r1, #1 
    str r1, [ssi_reg, #SSI_SSIENR_OFFSET] 

    movs r1, #CMD_READ 
    str r1, [ssi_reg, #SSI_DR0_OFFSET] 
    movs r1, #MODE_CONTINOUS_READ 
    str r1, [ssi_reg, #SSI_DR0_OFFSET] 

    bl wait_ssi_ready 

    movs r1, #0
    str r1, [ssi_reg, #SSI_SSIENR_OFFSET]

configure_ssi: 
    ldr r1, =(SPI_CTRLR0_XIP) 
    ldr r0, =(XIP_SSI_BASE + SSI_SPI_CTRLR0_OFFSET) 
    str r1, [r0]

    movs r1, #1 
    str r1, [ssi_reg, #SSI_SSIENR_OFFSET]

    b call_bootstrap 
 
call_bootstrap: 
    ldr r0, =(XIP_BASE + 0x101)
    //ldmia r0, {r0, r1} 
    //msr msp, r0 
    bx r0 
    b loop

loop: 
    wfi 
    b loop

.global read_flash_status_register
.type read_flash_status_register,%function 
.thumb_func 
read_flash_status_register:
    // r0 command 
    push {lr} 
    str r0, [ssi_reg, #SSI_DR0_OFFSET]
    // dummy byte
    str r0, [ssi_reg, #SSI_DR0_OFFSET]

    bl wait_ssi_ready 

    ldr r0, [ssi_reg, #SSI_DR0_OFFSET]
    ldr r0, [ssi_reg, #SSI_DR0_OFFSET]
    pop {pc}

.global wait_ssi_ready 
.type wait_ssi_ready,%function 
.thumb_func 
wait_ssi_ready:
    push {r1, r2, lr} 

ssi_ready_loop: 
    ldr r1, [ssi_reg, #SSI_SR_OFFSET]
    movs r2, #SSI_SR_TFE_BITS
    tst r1, r2 
    beq ssi_ready_loop
    movs r2, #SSI_SR_BUSY_BITS 
    tst r1, r2 
    bne ssi_ready_loop 
    pop {r1, r2, pc}


.global literals
literals: 
.ltorg
 
.end
