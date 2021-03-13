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

#include "clocks.hpp"
#include "register_manipulator.hpp"

#include "hardware/structs/clocks.h"
#include "hardware/structs/xosc.h"
#include "hardware/structs/resets.h"
#include "hardware/regs/resets.h"
#include "hardware/structs/pll.h"
#include "hardware/regs/pll.h"

extern "C" 
{
    void delay_clocks(uint32_t count);
}

constexpr uint32_t operator "" _MHz(unsigned long long int value)
{
    return value * 1000000;
}

constexpr uint32_t operator ""_KHz(unsigned long long int value)
{
    return value * 1000;
}

void xosc_init() 
{
    xosc_hw->ctrl = XOSC_CTRL_FREQ_RANGE_VALUE_1_15MHZ;

    constexpr uint32_t startup_delay = (12_KHz + 128) / 256;
    xosc_hw->startup = startup_delay; 

    set_bits(&xosc_hw->ctrl, XOSC_CTRL_ENABLE_VALUE_ENABLE << XOSC_CTRL_ENABLE_LSB); 

    while (!(xosc_hw->status & XOSC_STATUS_STABLE_BITS));
}

void bring_up_and_wait(uint32_t peripheral_bits)
{
    clear_bits(&resets_hw->reset, peripheral_bits);

    while (~resets_hw->reset_done & peripheral_bits);
}

bool has_glitchless_mux(clock_index index) 
{
    return index == clk_sys || index == clk_ref;
}

void pll_init(pll_hw_t* pll, uint32_t refdiv, uint32_t vco_freq, uint32_t post_div1, uint32_t post_div2)
{
    pll->pwr = 0xffffffff;
    pll->fbdiv_int = 0;

    pll->cs = refdiv;
   
    const uint32_t ref_freq = 1_MHz * (XOSC_MHZ / refdiv);
    const uint32_t fbdiv = vco_freq / ref_freq; 

    pll->fbdiv_int = fbdiv;

    clear_bits(&pll->pwr, PLL_PWR_PD_BITS | PLL_PWR_VCOPD_BITS);
    
    while (!(pll->cs & PLL_CS_LOCK_BITS)) 
    {
    }

    const uint32_t pdiv = (post_div1 << PLL_PRIM_POSTDIV1_LSB) |
        (post_div2 << PLL_PRIM_POSTDIV2_LSB);
    pll->prim = pdiv;
    clear_bits(&pll->pwr, PLL_PWR_POSTDIVPD_BITS);
}

static uint32_t configured_freq[CLK_COUNT];

bool clock_configure(clock_index clk_index, uint32_t src, uint32_t auxsrc, uint64_t src_freq, uint32_t freq)
{
    if (freq > src_freq)
    {
        return false; 
    }

    uint32_t div = (src_freq << 8 ) / freq;
    clock_hw_t* clk = &clocks_hw->clk[clk_index];

    if (div > clk->div) 
    {
        clk->div = div;
    }

    if (has_glitchless_mux(clk_index) && src == CLOCKS_CLK_SYS_CTRL_SRC_VALUE_CLKSRC_CLK_SYS_AUX) 
    {
        clear_bits(&clk->ctrl, CLOCKS_CLK_REF_CTRL_SRC_BITS);
        while (!(clk->selected & 1u)); 
    }
    else 
    {
        clear_bits(&clk->ctrl, CLOCKS_CLK_GPOUT0_CTRL_ENABLE_BITS);

        if (configured_freq[clk_index] > 0) 
        {
            uint32_t delay = configured_freq[clk_sys] / configured_freq[clk_index] + 1;
            delay_clocks(delay);
        }
    }

    write_bits(&clk->ctrl, (auxsrc << CLOCKS_CLK_SYS_CTRL_AUXSRC_LSB), CLOCKS_CLK_SYS_CTRL_AUXSRC_BITS);
    
    if (has_glitchless_mux(clk_index)) 
    {
        write_bits(&clk->ctrl, src << CLOCKS_CLK_REF_CTRL_SRC_LSB, CLOCKS_CLK_REF_CTRL_SRC_BITS);

        while (!(clk->selected & (1u << src)));
    }

    set_bits(&clk->ctrl, CLOCKS_CLK_GPOUT0_CTRL_ENABLE_BITS);

    clk->div = div;
    configured_freq[clk_index] = freq;

    return true;
}

void clocks_init()
{
    // deinitialize from previous run 
    clocks_hw->resus.ctrl = 0;
    
    xosc_init();

    clear_bits(&clocks_hw->clk[clk_sys].ctrl, CLOCKS_CLK_SYS_CTRL_SRC_BITS);

    while (clocks_hw->clk[clk_sys].selected != 0x1);

    clear_bits(&clocks_hw->clk[clk_ref].ctrl, CLOCKS_CLK_REF_CTRL_SRC_BITS);
    while (clocks_hw->clk[clk_sys].selected != 0x1);

    set_bits(&resets_hw->reset, RESETS_RESET_PLL_SYS_BITS | RESETS_RESET_PLL_USB_BITS);
    
    clear_bits(&resets_hw->reset, RESETS_RESET_PLL_SYS_BITS | RESETS_RESET_PLL_USB_BITS);

    bring_up_and_wait(RESETS_RESET_PLL_SYS_BITS | RESETS_RESET_PLL_USB_BITS);


    pll_init(pll_sys_hw, 1, 1500_MHz, 6, 2);
    pll_init(pll_usb_hw, 1, 480_MHz, 5, 2);

    clock_configure(clk_ref,
        CLOCKS_CLK_REF_CTRL_SRC_VALUE_XOSC_CLKSRC,
        0,
        12_MHz,
        12_MHz 
    );

    clock_configure(clk_sys, 
        CLOCKS_CLK_SYS_CTRL_SRC_VALUE_CLKSRC_CLK_SYS_AUX,
        CLOCKS_CLK_SYS_CTRL_AUXSRC_VALUE_CLKSRC_PLL_SYS,
        125_MHz,
        125_MHz);

    clock_configure(clk_usb, 
        0, 
        CLOCKS_CLK_USB_CTRL_AUXSRC_VALUE_CLKSRC_PLL_USB,
        48_MHz, 
        48_MHz); 

    clock_configure(clk_adc,
        0,
        CLOCKS_CLK_ADC_CTRL_AUXSRC_VALUE_CLKSRC_PLL_USB,
        48_MHz, 
        48_MHz);

    clock_configure(clk_peri, 
        0, 
        CLOCKS_CLK_PERI_CTRL_AUXSRC_VALUE_CLK_SYS, 
        125_MHz, 
        125_MHz 
    );
}
