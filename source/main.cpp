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

// #include <cstdio>
// #include <cstdint>
// #include <chrono>

// #include "board.hpp"

// #include "flash_configuration.hpp"
// #include <hal/time/sleep.hpp>
// #include <hal/reset/reset.hpp>

// #include "connection.hpp"
// #include "flasher.hpp"
// #include "printer.hpp"

// #include "hardware/sync.h"

// hal::interfaces::Usart& get_usart()
//{
//     return *board::interfaces::usarts()[0];
// }

// extern "C"
//{
//     void boot_firmware(std::size_t sp, std::size_t entry);
//     void blink();
// }

// int main()
//{
//     auto& usart = *board::interfaces::usarts()[0];
//     usart.init(115200);

//    msboot::IOPrinter printer([](std::string_view data){
//        get_usart().write(data);
//    });

//    msboot::Connection connection;
//    connection.on_boot([]{
//        msboot::IOPrinter printer([](std::string_view data){
//            get_usart().write(data);
//        });
//        printer << "Booting from: 0x" << msboot::hex <<
//        board::FlashParameters::app_start << msboot::endl; std::uintptr_t*
//        firmware =
//        reinterpret_cast<std::uintptr_t*>(board::FlashParameters::app_start);
//        printer << "SP: 0x" << msboot::hex << firmware[0] << msboot::endl;
//        printer << "PC: 0x" << msboot::hex << firmware[1] << msboot::endl;
//        uint32_t* VTOR = reinterpret_cast<uint32_t*>(0xe000ed08);
//        printer << "Old VTOR: 0x" << *VTOR << msboot::endl;
//        //uint32_t mask = save_and_disable_interrupts();
//        //*VTOR = board::FlashParameters::app_start;
//        //restore_interrupts(mask);
//        //get_usart().deinit();
// //       boot_firmware(firmware[0], firmware[1]);
//        //board::gpio::LED().set_high();
//        blink();
//    });

//    connection.on_reset_to_vendor_bootloader([]{
//        get_usart().write("Reset to vendor bootloader\r\n");
//        hal::reset::reset(hal::reset::Type::vendor_bootloader);
//    });

//    connection.on_flash([](uint8_t byte) {
//        msboot::IOPrinter printer([](std::string_view data){
//            get_usart().write(data);
//        });
//        static msboot::Flasher flasher([](){
//                return get_usart().read();
//            },
//            [](std::string_view data) {
//                get_usart().write(data);
//            },
//            printer
//        );
//        flasher.run(byte);
//    });

//    int i = 0;

//    while (true) {
//        char c = usart.read();
//        connection.run(c);
//    }
//}

// #include "arch/armv6-m/rp2040/usart.hpp"

// extern "C"
// {
// void blink();
// }

#include <pico/stdlib.h>
#include <stdio.h>

int main() {
  // board::gpio::LED().init(hal::gpio::Output::OpenDrain,
  // hal::gpio::Speed::Default, hal::gpio::PullUpPullDown::None);

  // board::gpio::LED().set_high();
  // init_usart(115200);
  // usart_puts("Hello world\r\n");
  stdio_init_all();
  while (true) {
  }
}
