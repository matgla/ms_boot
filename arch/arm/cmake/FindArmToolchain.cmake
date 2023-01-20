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

find_program(arm_eabi_c_compiler NAMES "arm-none-eabi-gcc")
find_program(arm_eabi_cxx_compiler NAMES "arm-none-eabi-g++")
find_program(arm_eabi_objcopy NAMES "arm-none-eabi-objcopy")
find_program(arm_eabi_objdump NAMES "arm-none-eabi-objdump")
find_program(arm_eabi_size NAMES "arm-none-eabi-size")
find_program(arm_eabi_gcc_ar NAMES "arm-none-eabi-gcc-ar")
find_program(arm_eabi_ranlib NAMES "arm-none-eabi-ranlib")

message(STATUS "ARM ASM compiler: ${arm_eabi_c_compiler}")
message(STATUS "ARM C compiler: ${arm_eabi_c_compiler}")
message(STATUS "ARM C++ compiler: ${arm_eabi_cxx_compiler}")
message(STATUS "ARM objcpy: ${arm_eabi_objcopy}")
message(STATUS "ARM objdump: ${arm_eabi_objdump}")
message(STATUS "ARM GCC AR: ${arm_eabi_gcc_ar}")
message(STATUS "ARM ranlib: ${arm-none-eabi-gcc-ar}")

set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

set(CMAKE_ASM_COMPILER ${arm_eabi_c_compiler})
set(CMAKE_C_COMPILER ${arm_eabi_c_compiler})
set(CMAKE_CXX_COMPILER ${arm_eabi_cxx_compiler})
set(CMAKE_OBJCOPY ${arm_eabi_objcopy})
set(CMAKE_OBJDUMP ${arm_eabi_objdump})
set(CMAKE_CXX_LINK_EXECUTABLE ${arm_eabi_cxx_compiler})
set(CMAKE_C_LINK_EXECUTABLE ${arm_eabi_c_compiler})
set(CMAKE_AR ${arm_eabi_gcc_ar})
set(CMAKE_C_COMPILER_AR ${arm_eabi_gcc_ar})
set(CMAKE_RANLIB ${arm_eabi_ranlib})
set(CMAKE_C_COMPILER_RANLIB ${arm_eabi_ranlib})

find_package(PackageHandleStandardArgs)
find_package_handle_standard_args(
  ArmToolchain
  DEFAULT_MSG
  arm_eabi_c_compiler
  arm_eabi_cxx_compiler
  arm_eabi_objcopy
  arm_eabi_objdump
  arm_eabi_gcc_ar
  arm_eabi_ranlib)
