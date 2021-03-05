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
#include "printer.hpp"

namespace msboot
{
logging_flags::logging_flags()
    : base_(base::dec)
    , boolalpha_(boolalpha::disabled)
{
}

void logging_flags::set_base(const base new_base)
{
    base_ = new_base;
}

logging_flags::base logging_flags::get_base() const
{
    return base_;
}

void logging_flags::set_boolalpha(const boolalpha new_boolalpha)
{
    boolalpha_ = new_boolalpha;
}

logging_flags::boolalpha logging_flags::get_boolalpha() const
{
    return boolalpha_;
}

IOPrinter::IOPrinter(const OutType& out)
    : out_(out) 
    , flags_()
{

}

IOPrinter& IOPrinter::operator<<(const EndlineTag)
{
    write("\n");
    return *this;
}

IOPrinter& IOPrinter::operator<<(const logging_flags::base base)
{
    flags_.set_base(base);
    return *this;
}

IOPrinter& IOPrinter::operator<<(const logging_flags::boolalpha b) 
{
    flags_.set_boolalpha(b);
    return *this;
}

IOPrinter& IOPrinter::operator<<(bool b) 
{
    write_bool(b);
    return *this;
}

void IOPrinter::write(const std::string_view& str)
{
    out_(str);
}


void IOPrinter::write(char data)
{
    char buf[] = { data, '\0' };
    out_(buf);
}

int IOPrinter::get_base() const
{
    switch (flags_.get_base())
    {
        case logging_flags::base::dec:
        {
            return 10;
        } break;
        case logging_flags::base::hex:
        {
            return 16;
        } break;
        case logging_flags::base::oct:
        {
            return 8;
        } break;
        case logging_flags::base::bin:
        {
            return 2;
        } break;
    }
    return 0;
}

void IOPrinter::write_bool(bool b) 
{
    if (flags_.get_boolalpha() == logging_flags::boolalpha::enabled)
    {
        if (b) 
        {
            write("true");
            return; 
        }
        write("false");
        return; 
    }
    write(static_cast<int>(b)); 
}

} // namespace msboot
