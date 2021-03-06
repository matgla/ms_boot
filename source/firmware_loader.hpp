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

#pragma once 

#include <cstdint>

#include <span>

#include <hal/memory/flash.hpp>

namespace msboot 
{

class FirmwareLoader 
{
public:
    FirmwareLoader(uint32_t flash_offset);

    using DataType = std::span<const uint8_t>;
    bool write_page(int page_number, const DataType& data);
private: 
    uint32_t flash_offset_;
    hal::memory::Flash flash_;
};

} // namespace msboot 

