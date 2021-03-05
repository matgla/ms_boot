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
import math 

ALIGNMENT = 256 
POLYNOMIAL = 0x04c11db7
parser = argparse.ArgumentParser(description = "Script to calculate and append checksum")

parser.add_argument("--input", dest="input", action="store", help="Path to bootloader binary file", required = True)
parser.add_argument("--output", dest="output", action="store", help="Path to bootloader output file", required = True)

args, rest = parser.parse_known_args()

with open(args.input, "rb") as input:
    with open(args.output, "wb") as output: 
        output.write(struct.pack("<I", 0x0a324655))
        output.write(struct.pack("<I", 0x9e5d5157))
        output.write(struct.pack("<I", 0x00002000))
        output.write(struct.pack("<I", 0x10000000))
        binary = input.read()
        number_of_blocks = int(math.ceil(len(binary) / 256))
        binary = binary[0:256]
        output.write(struct.pack("<I", 256))
        output.write(struct.pack("<I", 0))
        output.write(struct.pack("<I", number_of_blocks))
        output.write(struct.pack("<I", 0xe48bff56))
        output.write(binary)
        output.write(bytes(476 - len(binary)))
        output.write(struct.pack("<I", 0x0ab16f30))

