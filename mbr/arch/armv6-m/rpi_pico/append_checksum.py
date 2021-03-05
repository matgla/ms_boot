#!/usr/bin/python3
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

import argparse 
import binascii
import sys 
import struct 

ALIGNMENT = 256 
POLYNOMIAL = 0x04c11db7
parser = argparse.ArgumentParser(description = "Script to calculate and append checksum")

parser.add_argument("--input", dest="input", action="store", help="Path to bootloader binary file", required = True)
parser.add_argument("--output", dest="output", action="store", help="Path to bootloader output file", required = True)

args, rest = parser.parse_known_args()

def bitrev(x, width):
    # https://stackoverflow.com/questions/12681945/reversing-bits-of-python-integer
    return int("{:0{w}b}".format(x, w=width)[::-1], 2)

def bitrev_byte(x):
    return bitrev(x, 8)

def bitrev_data(data):
    return bytes(bitrev_byte(b) for b in data)

bootloader_binary = None 
print ("Processing file: ", args.input)
with open(args.input, "rb") as file:
    input_file = file.read() 
    if (len(input_file) > ALIGNMENT - 4):
        sys.exit("File is too large for bootloader code by (" + str(len(input_file) - (ALIGNMENT - 4)) + ")")

    input_padded = input_file + bytes(ALIGNMENT - 4 - len(input_file))

    seed = 0xffffffff
    mangled_seed = seed ^ 0xffffffff
    calculated_crc = binascii.crc32(bitrev_data(input_padded), mangled_seed) ^ 0xffffffff
    checksum = bitrev(calculated_crc & 0xffffffff, 32)
    packed_checksum = struct.pack("<L", checksum)
    print(hex(checksum))
    bootloader_binary = input_padded + packed_checksum

    with open(args.output, "wb") as output:
        output.write(bootloader_binary)
