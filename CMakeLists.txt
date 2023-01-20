# This file is part of ms_boot project. Copyright (C) 2023 Mateusz Stadnik
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program.  If not, see <https://www.gnu.org/licenses/>.

cmake_minimum_required(VERSION 3.19)

project(ms_boot NONE)

find_package(Python3 COMPONENTS Interpreter)

include(FetchContent)

FetchContent_Declare(
  yaspem
  GIT_REPOSITORY https://github.com/matgla/yaspem.git
  GIT_TAG master)

FetchContent_MakeAvailable(yaspem)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${yaspem_SOURCE_DIR}/cmake)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${PROJECT_SOURCE_DIR}/cmake)

include(GenerateConfig)
generate_config()

# KConfig settings
file(GLOB config ${PROJECT_BINARY_DIR}/.config)
if(NOT config)
  message(STATUS "Command: ${command}")
  execute_process(
    COMMAND
      ${CMAKE_COMMAND} -E env srctree=${PROJECT_SOURCE_DIR} BOARD_DIR=boards/**
      ${Python3_EXECUTABLE} ${PROJECT_SOURCE_DIR}/kconfig/kconfig/guiconfig.py
      ${PROJECT_SOURCE_DIR}/Kconfig COMMAND_ERROR_IS_FATAL ANY)
endif()

add_custom_target(
  menuconfig
  COMMAND
    ${CMAKE_COMMAND} -E env srctree=${PROJECT_SOURCE_DIR} BOARD_DIR=boards/**
    ${Python3_EXECUTABLE} ${PROJECT_SOURCE_DIR}/kconfig/kconfig/menuconfig.py
    ${PROJECT_SOURCE_DIR}/Kconfig
  VERBATIM)

set(CMAKE_EXPORT_COMPILE_COMMANDS
    ON
    CACHE INTERNAL "" FORCE)

# End of KConfig settings

include(parse_hw_config)
process_hw_configuration_file()
message(STATUS "NN: ${CMAKE_MODULE_PATH}")
include(yaspem)

set(user_boards_path
    ${PROJECT_SOURCE_DIR}/boards
    CACHE STRING "Path to boards provided from user")

include(GetPackageConfig)
getpackageconfig()

setup_yaspem(
  YASPEM_SOURCE ${yaspem_SOURCE_DIR} OUTPUT_DIRECTORY
  ${CMAKE_CURRENT_BINARY_DIR}/packages PACKAGE_FILES
  ${PROJECT_SOURCE_DIR}/packages.json,${ARCH_PACKAGE_FILES})

find_package(ArmToolchain REQUIRED)
find_package(rp2040 REQUIRED)

enable_language(ASM C CXX)

add_subdirectory(source)
# add_subdirectory(mbr/arch/armv6-m/rpi_pico)

execute_process(
  COMMAND
    ${CMAKE_COMMAND} -E create_symlink
    ${CMAKE_BINARY_DIR}/compile_commands.json
    ${PROJECT_SOURCE_DIR}/compile_commands.json)

# get_property(msboot_binary TARGET msboot PROPERTY TARGET_FILE)
# add_custom_target(msboot_image ALL DEPENDS mbr_boot mbr_prepare_flash
# ${FIRST_BOOTLOADER_BINARY} COMMAND ${Python3_EXECUTABLE}
# ${PROJECT_SOURCE_DIR}/scripts/append.py --input ${FIRST_BOOTLOADER_BINARY}
# --output first_boot.bin --size 512 COMMAND cat first_boot.bin
# $<TARGET_FILE:msboot>.bin > ${PROJECT_BINARY_DIR}/msboot.bin VERBATIM )
