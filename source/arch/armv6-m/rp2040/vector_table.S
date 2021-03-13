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
#include "hardware/regs/m0plus.h" 

.syntax unified 
.cpu cortex-m0plus 
.thumb 

.section .vector_table, "ax"
.align 2 

.global _vector_table
__vector_table:
.word _stack_top 
.word reset_handler 
.word nmi_handler
.word hardfault_handler 
.word interrupt_invalid
.word interrupt_invalid
.word interrupt_invalid
.word interrupt_invalid
.word interrupt_invalid
.word interrupt_invalid
.word interrupt_invalid
.word svc_handler
.word interrupt_invalid 
.word interrupt_invalid 
.word pendsv_handler
.word systick_handler
.word irq0_handler
.word irq1_handler
.word irq2_handler
.word irq3_handler
.word irq4_handler
.word irq5_handler
.word irq6_handler
.word irq7_handler
.word irq8_handler
.word irq9_handler
.word irq10_handler
.word irq11_handler
.word irq12_handler
.word irq13_handler
.word irq14_handler
.word irq15_handler
.word irq16_handler
.word irq17_handler
.word irq18_handler
.word irq19_handler
.word irq20_handler
.word irq21_handler
.word irq22_handler
.word irq23_handler
.word irq24_handler
.word irq25_handler
.word irq26_handler
.word irq27_handler
.word irq28_handler
.word irq29_handler
.word irq30_handler
.word irq31_handler

.macro declare_irq_handler name 
.weak \name 
.type \name,%function 
.thumb_func
\name:
    bkpt #0 
.endm 

declare_irq_handler nmi_handler 
declare_irq_handler hardfault_handler
declare_irq_handler interrupt_invalid
declare_irq_handler svc_handler 
declare_irq_handler pendsv_handler
declare_irq_handler systick_handler

.macro declare_fallthrough_handler name 
.weak \name
.type \name,%function 
.thumb_func 
\name:
.endm

declare_fallthrough_handler irq0_handler 
declare_fallthrough_handler irq1_handler 
declare_fallthrough_handler irq2_handler
declare_fallthrough_handler irq3_handler
declare_fallthrough_handler irq4_handler
declare_fallthrough_handler irq5_handler
declare_fallthrough_handler irq6_handler
declare_fallthrough_handler irq7_handler
declare_fallthrough_handler irq8_handler
declare_fallthrough_handler irq9_handler
declare_fallthrough_handler irq10_handler
declare_fallthrough_handler irq11_handler
declare_fallthrough_handler irq12_handler
declare_fallthrough_handler irq13_handler
declare_fallthrough_handler irq14_handler
declare_fallthrough_handler irq15_handler
declare_fallthrough_handler irq16_handler
declare_fallthrough_handler irq17_handler
declare_fallthrough_handler irq18_handler
declare_fallthrough_handler irq19_handler
declare_fallthrough_handler irq20_handler
declare_fallthrough_handler irq21_handler
declare_fallthrough_handler irq22_handler
declare_fallthrough_handler irq23_handler
declare_fallthrough_handler irq24_handler
declare_fallthrough_handler irq25_handler
declare_fallthrough_handler irq26_handler
declare_fallthrough_handler irq27_handler
declare_fallthrough_handler irq28_handler
declare_fallthrough_handler irq29_handler
declare_fallthrough_handler irq30_handler
declare_fallthrough_handler irq31_handler

.global _unhandled_user_interrupt
.thumb_func 
_unhandled_user_interrupt:
    bl _get_current_exception
    subs r0, #16 
    bkpt #0 

.global _get_current_exception
.thumb_func 
_get_current_exception:
    mrs r0, ipsr 
    uxtb r0, r0 
    bx lr

.section .reset_section

// For debugger purposes
.global _entry_point
.type _entry_point,%function 
.thumb_func 
_entry_point:
    movs r0, #0 
    ldr r1, =(PPB_BASE + M0PLUS_VTOR_OFFSET)
    str r0, [r1] 
    ldmia r0!, {r1, r2} 
    msr msp, r1 
    bx r2

.type reset_handler,%function
.thumb_func 
reset_handler: 
    ldr r0, =_sdata
    ldr r1, =_edata 
    ldr r2, =_sidata

loop_copy_data_init:
    ldm r2!, {r3} 
    stm r0!, {r3}
    cmp r0, r1 
    blo loop_copy_data_init

fill_bss:
    ldr r0, =_sbss 
    ldr r1, =_ebss 
    movs r2, #0
loop_fill_bss: 
    stm r0!, {r2}
    cmp r0, r1 
    bcc loop_fill_bss 

initialize_system: 
    bl system_init 
    bl __libc_init_array 
    bl main 
    bl _exit 

.type system_init,%function 
.weak system_init 
.thumb_func
system_init:
    bx lr

.global _exit 
.type _exit,%function 
.thumb_func 
_exit:
    bkpt #0
    wfi 
    b _exit 


.global delay_clocks
.type delay_clocks,%function 
.thumb_func
delay_clocks:
    subs r0, #1 
    bne delay_clocks 
    bx lr

.section text

.end
