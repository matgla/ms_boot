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

.cpu cortex-m0

.section .text 
.thumb

.global blink
.type blink,%function 

// GPIO CTRL 
// 31:30:29:28 27:26:25:24 
// reserved and irq        0x00 
// 23:22:21:20 19:18:17:16 
// irq                     0x00 
// 15:14:13:12 11:10:9:8 
// 0  0  0x3   0     0x02 -> low 0x03 -> high 
// 7:6:5:4     3:2:1:0
// 0x00        0x00 

// so for output high 
// 0x00003300
// low 
// 0x00003200

.thumb_func
blink: 
    push {r5, r6, r7}
    ldr r7, =0x400140cc // Address of GPIO25 Control Block 
    ldr r6, [r7]        // Load register value 
    ldr r5, =0x00003300 // GPIO 25/Output
    orr r6, r6, r5 
    str r6, [r7]
    pop {r5, r6, r7} 
    bx lr
    
