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

#include <array>

#include <hal/interfaces/usart.hpp> 

#include <rp2040_gpio.hpp>
#include <rp2040_usart.hpp>

namespace board 
{

void board_init();

namespace gpio 
{
static inline auto& LED = hal::gpio::P25;
} // namespace gpio 

namespace interfaces 
{

using UsartsType = std::array<hal::interfaces::Usart*, 1>;

UsartsType& usarts();

} // namespace interfaces



} // namespace board

