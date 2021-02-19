// This file is part of MSBOOT project.
// Copyright (C) 2021 Mateusz Stadnik
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

#include <cstdio>

#include "board.hpp" 

#include <hal/time/sleep.hpp>

int main() 
{
    board::gpio::LED().init(hal::gpio::Output::OpenDrain, hal::gpio::Speed::Default, hal::gpio::PullUpPullDown::None);

    auto& usart = *board::interfaces::usarts()[0];
    usart.init(115200);
    while (true) {
        board::gpio::LED().set_low(); 
        usart.write("Hello\n");
        hal::time::sleep(std::chrono::milliseconds(250));
        board::gpio::LED().set_high();
        usart.write("World\n");
        uint8_t buf[2];
        buf[1] = 0;
        buf[0] = usart.read();     
        usart.write(buf);
        hal::time::sleep(std::chrono::milliseconds(250));
    }
}

