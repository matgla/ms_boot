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

extern "C"
{
#include <hardware/flash.h>
}

namespace msboot 
{

FirmwareLoader::FirmwareLoader(uint32_t flash_offset)
    : flash_offset_(flash_offset)
{
}

bool FirmwareLoader::write_page(int page_number, const DataType& data) 
{
    if (data.size() != FLASH_PAGE_SIZE)
    {
        return false; 
    }

    const uint32_t page_address = flash_offset_ + page_number * FLASH_PAGE_SIZE;
    if (page_number * FLASH_PAGE_SIZE % FLASH_SECTOR_SIZE == 0)
    {
        flash_range_erase(page_address, FLASH_PAGE_SIZE);
        printf("Erasing at 0x%x with size %d\n", page_address, FLASH_PAGE_SIZE);
    }
    printf("Program memory at 0x%x\n", page_address);
    
    flash_range_program(page_address, data.data(), FLASH_PAGE_SIZE);
    return true;
}

} // namespace msboot

