# This file is part of msboot project.
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

add_executable(mbr_prepare_flash)

target_sources(mbr_prepare_flash 
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/boot_configure_flash.S
)

target_link_libraries(mbr_prepare_flash 
    PRIVATE 
        hardware_regs
)

target_link_options(mbr_prepare_flash PRIVATE "--specs=nosys.specs;-nostartfiles")
target_link_options(mbr_prepare_flash PRIVATE "LINKER:--script=${CMAKE_CURRENT_SOURCE_DIR}/boot_prepare_flash.ld")

set_target_properties(mbr_prepare_flash PROPERTIES LINK_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/boot.ld)

find_package(Python3 COMPONENTS Interpreter REQUIRED)
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/append_checksum.py)
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/make_uf2.py)

add_custom_command(
    TARGET mbr_prepare_flash  
    POST_BUILD
    COMMAND 
      ${CMAKE_OBJCOPY} -Obinary $<TARGET_FILE:mbr_prepare_flash> mbr_prepare_flash.bin
    COMMAND 
    ${Python3_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/append_checksum.py --input
    ${CMAKE_CURRENT_BINARY_DIR}/mbr_prepare_flash.bin --output ${CMAKE_CURRENT_BINARY_DIR}/boot_prepare_flash.bin
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/append_checksum.py
    VERBATIM
)

add_executable(mbr_boot) 

target_sources(mbr_boot 
    PUBLIC 
        ${CMAKE_CURRENT_SOURCE_DIR}/boot.S 
)

target_link_options(mbr_boot PRIVATE "--specs=nosys.specs;-nostartfiles")
target_link_options(mbr_boot PRIVATE "LINKER:--script=${CMAKE_CURRENT_SOURCE_DIR}/boot.ld")

target_link_libraries(mbr_boot 
    PRIVATE 
        hardware_regs
)

set_target_properties(mbr_boot PROPERTIES LINK_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/boot.ld)

set_target_properties(mbr_boot PROPERTIES COMPILE_DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/boot_prepare_flash.bin)

set_source_files_properties(${CMAKE_CURRENT_BINARY_DIR}/boot_prepare_flash.bin PROPERTIES GENERATED TRUE)

set (clean_bin ON)
# include (GenerateBinary) 
# generate_binary(mbr_boot ${vendor})
add_dependencies(mbr_boot mbr_prepare_flash)
add_custom_command(
    TARGET mbr_boot 
    POST_BUILD
    COMMAND 
      ${CMAKE_OBJCOPY} -Obinary $<TARGET_FILE:mbr_boot> mbr_boot.bin
    COMMAND 
    ${Python3_EXECUTABLE} ${PROJECT_SOURCE_DIR}/scripts/append.py --input ${CMAKE_CURRENT_BINARY_DIR}/mbr_boot.bin
    --output ${CMAKE_CURRENT_BINARY_DIR}/boot_bootstrap.bin --size 190
    
    DEPENDS ${PROJECT_SOURCE_DIR}/scripts/append.py mbr_prepare_flash ${CMAKE_CURRENT_SOURCE_DIR}/boot_prepare_flash.bin
    VERBATIM
)

add_custom_target(image 
    ALL 
    DEPENDS mbr_boot mbr_prepare_flash
    COMMAND
      cat boot_prepare_flash.bin boot_bootstrap.bin > boot.bin
    COMMAND
      ${PROJECT_SOURCE_DIR}/scripts/append.py --input boot.bin --output mbr.bin --size 512 
    VERBATIM 
)

set (mbr_binary_path ${CMAKE_CURRENT_BINARY_DIR}/mbr.bin)

