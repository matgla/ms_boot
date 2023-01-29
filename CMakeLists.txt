# This file is part of ms_boot project. 
# Copyright (C) 2023 Mateusz Stadnik
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

find_package(Python3 COMPONENTS Interpreter)

include(FetchContent)

FetchContent_Declare(
  yaspem
  GIT_REPOSITORY https://github.com/matgla/yaspem.git
  GIT_TAG master)

FetchContent_MakeAvailable(yaspem)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${yaspem_SOURCE_DIR}/cmake)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/GenerateConfig.cmake)
generate_config(${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR})
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
include(cmake/parse_hw_config.cmake)
process_hw_configuration_file(${CMAKE_CURRENT_SOURCE_DIR})

include(yaspem)

setup_yaspem(
  YASPEM_SOURCE ${yaspem_SOURCE_DIR} OUTPUT_DIRECTORY
  ${CMAKE_CURRENT_BINARY_DIR}/packages PACKAGE_FILES
  ${CMAKE_CURRENT_SOURCE_DIR}/packages.json,${CMAKE_CURRENT_SOURCE_DIR}/cpu/${cpu_name}/packages.json)

find_package(${cpu_name} REQUIRED)

project(ms_boot ASM C CXX)

initialize_cpu()

add_subdirectory(source)

execute_process(
  COMMAND
    ${CMAKE_COMMAND} -E create_symlink
    ${CMAKE_BINARY_DIR}/compile_commands.json
    ${PROJECT_SOURCE_DIR}/compile_commands.json)


add_subdirectory(mbr/arch/armv6-m/rpi_pico)

add_custom_target(msboot_image
  ALL 
  DEPENDS ${mbr_binary_path} hello 
  COMMAND 
  cat ${mbr_binary_path} ${CMAKE_CURRENT_BINARY_DIR}/source/hello.bin > ${PROJECT_BINARY_DIR}/msboot.bin
  VERBATIM
)

