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

#include "hardware/regs/resets.h"
#include "hardware/resets.h"

#include "clocks.hpp"

extern "C" 
{

void system_init() 
{
    reset_block(~(
        RESETS_RESET_IO_QSPI_BITS   |
        RESETS_RESET_PADS_QSPI_BITS |
        RESETS_RESET_PLL_USB_BITS   |
        RESETS_RESET_PLL_SYS_BITS));

    unreset_block_wait(RESETS_RESET_BITS & ~(
        RESETS_RESET_ADC_BITS |
        RESETS_RESET_RTC_BITS |
        RESETS_RESET_SPI0_BITS | 
        RESETS_RESET_SPI1_BITS |
        RESETS_RESET_UART0_BITS |
        RESETS_RESET_UART1_BITS |
        RESETS_RESET_USBCTRL_BITS 
    ));

    clocks_init();

    unreset_block_wait(RESETS_RESET_BITS);
}

}
