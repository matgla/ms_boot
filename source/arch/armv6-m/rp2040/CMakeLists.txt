# This file is part of ms_boot project.
# Copyright (C) 2021 Mateusz Stadnik
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

set (library_name msboot_rp2040)

add_library(${library_name} STATIC)

target_sources(${library_name}
    PUBLIC 
        ${CMAKE_CURRENT_SOURCE_DIR}/register_manipulator.hpp
        ${CMAKE_CURRENT_SOURCE_DIR}/clocks.hpp 
        ${CMAKE_CURRENT_SOURCE_DIR}/usart.hpp 
        #PRIVATE 
        ${CMAKE_CURRENT_SOURCE_DIR}/system_init.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/clocks.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/usart.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/syscalls.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/crt0.S
)

target_compile_options(${library_name}
  PUBLIC
    -fno-exceptions
    -fno-rtti
    -Os
    -ffunction-sections
    -fdata-sections
    -fno-threadsafe-statics
    -fno-use-cxa-atexit
    -fno-common
)

target_link_options(${library_name}
  PUBLIC
     -flto
     -Wl,--gc-sections
)
target_link_options(${library_name} PUBLIC "--specs=nano.specs;-nostartfiles")
target_link_options(${library_name} PUBLIC "LINKER:--script=${CMAKE_CURRENT_SOURCE_DIR}/linker_script.ld")

set_target_properties(${library_name} PROPERTIES LINK_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/linker_script.ld)

target_link_libraries(${library_name} 
  PUBLIC 
    hardware_regs
    hardware_structs
    hardware_resets
    pico_bootrom
)

target_include_directories(${library_name} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
