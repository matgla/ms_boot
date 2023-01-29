/* linker_script.ld  
 * 
 * Copyright (C) 2023 Mateusz Stadnik <matgla@live.com>
 * 
 * This program is free software: you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation, either version
 * 3 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 * PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General
 * Public License along with this program. If not, see
 * <https://www.gnu.org/licenses/>.
*/

MEMORY {
  mbr(rx)     : ORIGIN = 0x10000000, LENGTH = 0x200 
  bootrom(rx) : ORIGIN = 0x10000200, LENGTH = 0x1000
  ram(rwx)    : ORIGIN = 0x20000000, LENGTH = 256k
}

__bootrom_start__ = ORIGIN(bootrom);
__bootrom_size__ = LENGTH(bootrom);

SECTIONS {
  .text : {
    KEEP(*(.vectors))
    KEEP(*(.reset))
    *(.text*)
  } > bootrom 

  .rodata : {
    *(.rodata*)
    . = ALIGN(4);
    __rodata_end__ = .; 
  } > bootrom 

  .data : {
    __data_start__ = .;
    . = ALIGN(4);
    *(.data*)
    . = ALIGN(4);
    __data_end__ = .;
  } > ram AT> bootrom

  .bss : {
    . = ALIGN(4);
    __bss_start__ = .;
    *(SORT_BY_ALIGNMENT(SORT_BY_NAME(.bss*)))
    *(COMMON)
    . = ALIGN(4);
    __bss_end__ = .;
  } > ram
  _stack_top = ORIGIN(ram) + LENGTH(ram);
}
