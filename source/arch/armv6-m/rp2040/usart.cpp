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

// This is temporary solution, target is to place in HAL with specificHAL target 

#include "usart.hpp"

#include <limits>

#include "hardware/regs/uart.h"
#include "hardware/structs/uart.h"
#include "hardware/structs/resets.h"
#include "hardware/regs/uart.h"
#include "hardware/regs/sio.h"
#include "hardware/structs/sio.h"
#include "hardware/structs/padsbank0.h"
#include "hardware/structs/iobank0.h"

#include "register_manipulator.hpp"

uint32_t set_baudrate(int baudrate)
{
    uint32_t baud_div = (125000000u << 2) / baudrate;
    uint32_t baud_brdi = baud_div >> 6;
    uint32_t baud_brdf = (baud_div & 0x3f);
    
    if (baud_brdi == std::numeric_limits<uint16_t>::min()) 
    {
        baud_brdi = 1;
        baud_brdf = 0;
    }
    else if (baud_brdi >= std::numeric_limits<uint16_t>::max())
    {
        baud_brdi = std::numeric_limits<uint16_t>::max();
        baud_brdf = 0;
    }

    uart0_hw->ibrd = baud_brdi;
    uart0_hw->fbrd = baud_brdf;

    set_bits(&uart0_hw->lcr_h, 0);

    // real baudrate
    return (125000000u << 2) / ((baud_brdi << 6) + baud_brdf);
}

void init_usart(int baudrate)
{
    set_bits(&resets_hw->reset, RESETS_RESET_UART0_BITS);
    
    clear_bits(&resets_hw->reset, RESETS_RESET_UART0_BITS);

    set_baudrate(baudrate);
    
    uint32_t data_bits = 8;
    uint32_t stop_bits = 1;
    uint32_t parity = 0;

    write_bits(&uart0_hw->lcr_h, 
            ((data_bits - 5u) << UART_UARTLCR_H_WLEN_LSB) |
            ((stop_bits - 1u) << UART_UARTLCR_H_STP2_LSB) |
            (parity << UART_UARTLCR_H_PEN_LSB), 
            UART_UARTLCR_H_WLEN_BITS |
            UART_UARTLCR_H_STP2_BITS |
            UART_UARTLCR_H_PEN_BITS |
            UART_UARTLCR_H_EPS_BITS);

    uart0_hw->cr = UART_UARTCR_UARTEN_BITS 
        | UART_UARTCR_TXE_BITS 
        | UART_UARTCR_RXE_BITS; 

    set_bits(&uart0_hw->lcr_h, UART_UARTLCR_H_FEN_BITS);

    uart0_hw->dmacr = UART_UARTDMACR_TXDMAE_BITS | UART_UARTDMACR_RXDMAE_BITS;

    write_bits(&padsbank0_hw->io[0], PADS_BANK0_GPIO0_IE_BITS, 
            PADS_BANK0_GPIO0_IE_BITS | PADS_BANK0_GPIO0_OD_BITS);

    iobank0_hw->io[0].ctrl = 2 << IO_BANK0_GPIO0_CTRL_FUNCSEL_LSB;
    write_bits(&padsbank0_hw->io[1], PADS_BANK0_GPIO0_IE_BITS, 
            PADS_BANK0_GPIO0_IE_BITS | PADS_BANK0_GPIO0_OD_BITS);

    iobank0_hw->io[1].ctrl = 2 << IO_BANK0_GPIO0_CTRL_FUNCSEL_LSB;
}

void uart_putc(char c)
{
    while ((uart0_hw->fr & UART_UARTFR_TXFF_BITS))
    {
    }

    uart0_hw->dr = c; 
}

void usart_puts(std::string_view data)
{
    for (char c : data) 
    {
        uart_putc(c);
    }
}

