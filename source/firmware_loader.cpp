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

#include "firmware_loader.hpp"

#include <cstdio>

#include <hal/memory/flash.hpp>

#include "flash_configuration.hpp"

namespace msboot 
{

FirmwareLoader::FirmwareLoader(uint32_t flash_offset)
    : flash_offset_(flash_offset)
{
}

bool FirmwareLoader::write_page(int page_number, const DataType& data) 
{
    if (data.size() != board::FlashParameters::page_size)
    {
        return false; 
    }

    const uint32_t page_address = flash_offset_ + page_number * board::FlashParameters::page_size;
    if (page_number * board::FlashParameters::page_size % board::FlashParameters::sector_size == 0)
    {
        
        flash_.erase(page_address, board::FlashParameters::sector_size);
    }
    
    flash_.write(page_address, data);
    return true;
}

} // namespace msboot

