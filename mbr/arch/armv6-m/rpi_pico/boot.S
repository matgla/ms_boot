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

#include "hardware/regs/m0plus.h"
#include "hardware/regs/addressmap.h"

.syntax unified 
.cpu cortex-m0plus 
.thumb 

.section .text 

.global _boot 
.type _boot,%function 
.thumb_func
_boot: 
    ldr r0, =(_msboot_start)
    ldr r1, =(PPB_BASE + M0PLUS_VTOR_OFFSET)
    str r0, [r1]
    ldmia r0, {r0, r1} 
    msr msp, r0
    bx r1

// .global literals 
// literals: 
// .ltorg

.end
