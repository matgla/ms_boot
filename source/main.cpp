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
#include <cstdint>
#include <chrono>

#include "board.hpp" 

#include <hal/time/sleep.hpp>
#include <hal/reset/reset.hpp>

#include "connection.hpp"


int main() 
{
    board::gpio::LED().init(hal::gpio::Output::OpenDrain, hal::gpio::Speed::Default, hal::gpio::PullUpPullDown::None);

    auto& usart = *board::interfaces::usarts()[0];
    usart.init(115200);
    
    msboot::Connection connection;
    connection.on_boot([]{
        auto& usart = *board::interfaces::usarts()[0];
        usart.write("On boot\r\n");
    });
    connection.on_reset_to_vendor_bootloader([]{
        auto& usart = *board::interfaces::usarts()[0];
        usart.write("Reset to vendor bootloader\r\n");
        hal::reset::reset(hal::reset::Type::vendor_bootloader);
    });
    while (true) {
        char c = usart.read();     
        connection.run(c);    
    }
}

