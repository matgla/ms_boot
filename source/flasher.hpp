// This file is part of msboot project.
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

#pragma once 

#include <array>
#include <cstdint>
#include <string_view>

#include <eul/function.hpp>

#include "flash_configuration.hpp"
#include "firmware_loader.hpp"
#include "printer.hpp"


namespace msboot 
{

class Flasher 
{
public:
    using OutputCallback = eul::function<void(std::string_view), sizeof(void*)>;  
    using InputCallback = eul::function<uint8_t(void), sizeof(void*)>;
    Flasher(const InputCallback& input, const OutputCallback& output_callback, IOPrinter& printer); 

    void run(uint8_t byte);
private: 
    template <typename T> 
    T receive();

    using BufferType = std::array<uint8_t, board::FlashParameters::page_size>;

    uint32_t receive_page(BufferType* buffer, uint32_t bytes_to_receive);
    
    InputCallback in_;
    OutputCallback out_;
    IOPrinter& printer_; 
    FirmwareLoader loader_;
};

} // namespace msboot

