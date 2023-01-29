#!/usr/bin/python3

# This file is part of msboot project.
# Copyright (C) 2023 Mateusz Stadnik
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

from pyocd.core.helpers import ConnectHelper
from pyocd.flash.file_programmer import FileProgrammer

parser = argparse.ArgumentParser(description="Script to flash Rasbperry PICO via TCL connection towards OpenOCD")
parser.add_argument("--image", dest="image",
    action="store", help="Path to file to flash (currently supported only .bin format)", required=True)
parser.add_argument("--tcl_port", dest="tcl_port", action="store", help="TCL server port")
parser.add_argument("--tcl_address", dest="tcl_address", action="store", help="TCL server IP address")
args, rest = parser.parse_known_args()

with ConnectHelper.session_with_chosen_probe() as session:
    board = session.board
    target = board.target 
    target.halt()
    target.resume()
