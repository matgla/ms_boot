set (arch_common_compile_flags -mthumb -march=armv6-m -mcpu=cortex-m0plus -fno-builtin -fdata-sections -ffunction-sections)
set (arch_linker_flags +)

set (CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} ${arch_common_compile_flags} -mno-rtti -fno-exceptions)
set (CMAKE_C_FLAGS ${arch_common_compile_flags})
set (CMAKE_ASM_FLAGS ${arch_common_compile_flags})

find_package (pico_sdk REQUIRED)
