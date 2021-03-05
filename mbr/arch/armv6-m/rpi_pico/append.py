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
import sys 

parser = argparse.ArgumentParser(description = "Script to calculate and append checksum")

parser.add_argument("--input", dest="input", action="store", help="Path to bootloader binary file", required = True)
parser.add_argument("--output", dest="output", action="store", help="Path to bootloader output file", required = True)
parser.add_argument("--size", dest="size", action="store", help="Expected size of final binary") 

args, rest = parser.parse_known_args()

args.size = int(args.size)
bootloader_binary = None 
print ("Processing file: ", args.input)
with open(args.input, "rb") as file:
    input_file = file.read() 
    if (len(input_file) >= args.size):
        sys.exit("File is too large by (" + str(len(input_file) - args.size) + ")")

    input_padded = input_file + bytes(args.size - len(input_file))

    with open(args.output, "wb") as output:
        output.write(input_padded)
