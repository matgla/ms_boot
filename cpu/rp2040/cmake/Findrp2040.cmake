set(arch_common_compile_flags
    "-mthumb -march=armv6-m -mcpu=cortex-m0plus -fno-builtin -fdata-sections -ffunction-sections"
)

set(CMAKE_CXX_FLAGS
    "${CMAKE_CXX_FLAGS} ${arch_common_compile_flags} -fno-rtti -fno-exceptions")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${arch_common_compile_flags}")
set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} ${arch_common_compile_flags}")

find_package(pico_sdk REQUIRED)

set(arch_linker_flags -mthumb -mcpu=cortex-m0plus -flto -lstdc++_nano
                      --specs=nano.specs)

set(arch_cxx_linker_flags ${arch_linker_flags})

add_library(arch_flags INTERFACE)

target_link_options(arch_flags INTERFACE ${arch_cxx_linker_flags})
