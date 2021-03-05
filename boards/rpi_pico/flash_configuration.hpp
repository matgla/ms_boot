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

#include <cstdint>

namespace board 
{

extern "C"
{
extern char _app_start;
extern char _app_offset;
extern char __flash_binary_start;
}

struct FlashParameters
{
    constexpr static uint32_t page_size      = 0x100;
    constexpr static uint32_t sector_size    = 0x1000;
    constexpr static uint32_t block_size     = 0x10000;
    static inline uintptr_t bootloader_start = reinterpret_cast<uintptr_t>(&__flash_binary_start);
    static inline uintptr_t app_start   = reinterpret_cast<uintptr_t>(&_app_start); 
    static inline uintptr_t app_offset = reinterpret_cast<uintptr_t>(&_app_offset);
};

} // namespace board

