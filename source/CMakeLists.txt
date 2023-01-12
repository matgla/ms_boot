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

set (CMAKE_CXX_STANDARD 20)

# add_executable(msboot) 

# add_subdirectory(arch)

# target_link_libraries(msboot 
#     PRIVATE 
#         # msboot_arch 
#         hal
# )

# target_sources(msboot 
#     PRIVATE 
# #        ${CMAKE_CURRENT_SOURCE_DIR}/configuration.hpp
# #        ${CMAKE_CURRENT_SOURCE_DIR}/connection.hpp
# #        ${CMAKE_CURRENT_SOURCE_DIR}/flasher.hpp 
# #        ${CMAKE_CURRENT_SOURCE_DIR}/firmware_loader.hpp 
# #        ${CMAKE_CURRENT_SOURCE_DIR}/printer.hpp

#         ${CMAKE_CURRENT_SOURCE_DIR}/main.cpp 
# #        ${CMAKE_CURRENT_SOURCE_DIR}/configuration.cpp
# #        ${CMAKE_CURRENT_SOURCE_DIR}/connection.cpp
# #        ${CMAKE_CURRENT_SOURCE_DIR}/flasher.cpp
# #        ${CMAKE_CURRENT_SOURCE_DIR}/firmware_loader.cpp
# #        ${CMAKE_CURRENT_SOURCE_DIR}/printer.cpp
# #        ${CMAKE_CURRENT_SOURCE_DIR}/functions.s
#         ${CMAKE_CURRENT_SOURCE_DIR}/blink.s
# )

#target_link_libraries(msboot
#    PRIVATE 
#        hal 
#)

# include (GenerateBinary)
# generate_binary(msboot ${vendor})

find_package(pico_sdk REQUIRED)

add_executable(hello
    ${CMAKE_CURRENT_SOURCE_DIR}/test.cpp
)

target_link_libraries(hello 
    PUBLIC
        hal 
        # msboot_arch
)

pico_enable_stdio_usb(hello 1)
pico_enable_stdio_uart(hello 0)

pico_add_extra_outputs(hello)
