#include <stdio.h>

#include <pico/stdlib.h>

#include "board.hpp"

#include <hal/time/sleep.hpp>

int main() 
{
    stdio_init_all();
    board::gpio::LED().init(hal::gpio::Output::OpenDrain, 
        hal::gpio::Speed::Default, 
        hal::gpio::PullUpPullDown::None);

    board::gpio::LED().set_high();
    while (true)
    {
        printf("Hello, World 2!\n");
        hal::time::sleep(std::chrono::milliseconds(1000));
        board::gpio::LED().set_low();
        hal::time::sleep(std::chrono::milliseconds(1000));
        board::gpio::LED().set_high();
    }
    return 0;
}