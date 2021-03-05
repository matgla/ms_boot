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

#include "flasher.hpp"

#include <eul/utils/string.hpp>
#include <eul/crc/crc.hpp>

#include <cstdio>

namespace msboot 
{

Flasher::Flasher(const InputCallback& input_callback,
        const OutputCallback& output_callback,
        IOPrinter& printer)
    : in_(input_callback)
    , out_(output_callback)
    , printer_(printer)
    , loader_(board::FlashParameters::app_offset)
{
}

template <typename T>
T Flasher::receive() 
{
    T data = 0;
    for (int i = 0; i < sizeof(T)/sizeof(uint8_t); ++i)
    {
        T byte = in_();
        byte <<= (i * 8);
        data |= byte;
    }

    return data;
}

void Flasher::run(uint8_t byte)
{
    uint32_t firmware_size = receive<uint32_t>();
    printer_ << "Firmware size: " << msboot::dec << firmware_size << "B" << msboot::endl;
    uint32_t firmware_crc = receive<uint32_t>();
    printer_ << "Firmware CRC: 0x" << msboot::hex << firmware_crc << msboot::endl;

    BufferType buffer;
    
    uint32_t received_bytes = 0;
    uint32_t received_pages = 0; 
    
    printer_ << "Application address: 0x" << msboot::hex << board::FlashParameters::app_start << msboot::endl; 
    printer_ << "Application offset: 0x" << msboot::hex << board::FlashParameters::app_offset << msboot::endl; 

    while (received_bytes < firmware_size)
    {
        uint32_t bytes_to_receive = (firmware_size - received_bytes) 
            < board::FlashParameters::page_size 
            ? (firmware_size - received_bytes) 
            : board::FlashParameters::page_size;
        const uint32_t page_address = board::FlashParameters::app_offset + received_pages * board::FlashParameters::page_size;
        bool erasing = false; 
        if (received_pages * board::FlashParameters::page_size % board::FlashParameters::sector_size == 0)
        {
            erasing = true;
        }
        received_bytes += receive_page(&buffer, bytes_to_receive); 
        loader_.write_page(received_pages++, buffer);
        printer_ << "ACK, received bytes: " << msboot::dec << received_bytes << msboot::endl;
    }

    const uint8_t* firmware = reinterpret_cast<const uint8_t*>(board::FlashParameters::app_start);
    uint32_t crc = calculate_crc32(std::span<const uint8_t>(firmware, firmware_size));
    if (crc == firmware_crc) 
    {
        printer_ << "CRC verification passed" << msboot::endl; 
    }
    else 
    {
        printer_ << "CRC verification failed" << msboot::endl 
            << "expected 0x" << msboot::hex << firmware_crc << msboot::endl 
            << "received 0x" << msboot::hex << crc << msboot::endl;
    }
    printer_ << "==FINISHED==" << msboot::endl;
}

uint32_t Flasher::receive_page(BufferType* buffer, uint32_t bytes_to_receive)
{
    buffer->fill(0);
    for (uint32_t i = 0; i < bytes_to_receive; ++i)
    {
        uint8_t byte = receive<uint8_t>();
        (*buffer)[i] = byte;
    }
    return bytes_to_receive;
}

} // namespace msboot

