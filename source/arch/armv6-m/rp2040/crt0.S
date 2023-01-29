// 
// crt0.s
// 
// Copyright (C) 2023 Mateusz Stadnik <matgla@live.com>
// 
// This program is free software: you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version
// 3 of the License, or (at your option) any later version.
// 
// This program is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
// PURPOSE. See the GNU General Public License for more details.
// 
// You should have received a copy of the GNU General
// Public License along with this program. If not, see
// <https://www.gnu.org/licenses/>.

#include "pico.h"
#include "hardware/regs/m0plus.h"
#include "hardware/regs/addressmap.h"
#include "hardware/regs/sio.h"

.syntax unified
.cpu cortex-m0plus
.thumb

.section .vectors, "ax"
.align 2 

.global __vector_table, __VECTOR_TABLE
__VECTOR_TABLE:
__vector_table:
.word _stack_top 
.word _reset_handler 
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp
.word isr_unimp

.macro decl_isr_bkpt name
.weak \name
.type \name,%function
.thumb_func
\name:
  bkpt #0 
.endm 

decl_isr_bkpt isr_invalid 
decl_isr_bkpt isr_nmi 
decl_isr_bkpt isr_hardfault
decl_isr_bkpt isr_svcall
decl_isr_bkpt isr_pendsv
decl_isr_bkpt isr_unimp

.section .reset

.type _entry_point,%function
.thumb_func
.global _entry_point
_entry_point:
  bkpt #0

.type _reset_handler,%function
.thumb_func
.global _reset_handler
_reset_handler: 
  bkpt #0
  ldr r0, =(SIO_BASE + SIO_CPUID_OFFSET)
  ldr r0, [r0]
  cmp r0, #0 
  bne hold_secondary_core_in_bootrom 
 
  // fill bss with zeros
copy_data:
  ldr r1, =__rodata_end__
  ldr r2, =__data_start__
  ldr r3, =__data_end__
  b is_data_fully_filled

copy_next_data:
  ldm r1!, {r0}
  stm r2!, {r0}

is_data_fully_filled:
  cmp r2, r3
  blo copy_next_data

fill_bss:
  movs r0, #0 
  ldr r1, =__bss_start__
  ldr r2, =__bss_end__
  b is_bss_fully_filled

bss_fill_next:
  stm r1!, {r0}

is_bss_fully_filled:
  cmp r1, r2
  bne bss_fill_next

process_init:
  ldr r1, =system_init
  bx r1
  ldr r1, =main
  bx r1


hold_secondary_core_in_bootrom:
  ldr r0, = 'W' | ('V' << 8)
  bl rom_func_lookup 
  bx r0


