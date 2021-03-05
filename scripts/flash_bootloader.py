#!/usr/bin/python3

# This file is part of MSBOOT Pico project.
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
import json
import subprocess
import serial
import time

def flash_firmware(args):
    print ("Flashing firmware")

    rc = subprocess.call(["mount " + args.mount], shell=True)

    if rc == 0:
        subprocess.call(["cp " + args.image + " /mnt/rpi_pico -v"], shell=True)
        subprocess.call(["cd /mnt/rpi_pico && sync"], shell=True)
    else:
        print("Mouting failed")
        time.sleep(1)
        flash_firmware(args)

    while True:
        files = subprocess.check_output(["ls /mnt/rpi_pico"], stderr=subprocess.PIPE, shell=True)
        if (len(files) == 0):
            return 0
    return 0


def restart_to_bootloader(port, baudrate):
    print ("Restarting to bootloader")
    with serial.Serial(port, baudrate=baudrate) as ser:
        ser.write('q'.encode("utf-8"))
        print(ser.readline().decode())


parser = argparse.ArgumentParser(description="Script to flash Rasbperry PICO from command line")
parser.add_argument("--mount", dest="mount",
    action="store", help="Mount point for Raspberry PICO", required=True)
parser.add_argument("--image", dest="image",
    action="store", help="Path to image for flash", required=True)
parser.add_argument("--serial", dest="serial",
    action="store", help="Serial port to send restart command")
parser.add_argument("--restart", dest="restart",
    action="store_true", help="Restart to pico bootloader (application must support it)")
parser.add_argument("--baudrate", dest="baudrate", action="store", help="Serial port baudrate")
args, rest = parser.parse_known_args()

if args.restart:
    restart_to_bootloader(args.serial, args.baudrate)

flash_firmware(args)
