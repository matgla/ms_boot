MEMORY {
    FLASH(rx) : ORIGIN = 0x10000200, LENGTH = 12K
    RAM(rwx)  : ORIGIN = 0x20000000, LENGTH = 128K 
}

SECTIONS {
    . = ORIGIN(FLASH);
    .vector_table : {
        KEEP (*(.vector_table))
        . = ALIGN(4);
    } > FLASH
    .text : {
        . = ALIGN(4);
        _stext = .;
        *(.text*)
        *(.glue_7) 
        *(.glue_7t)
        *(.eh_frame*) 
        KEEP (*(.reset_section))
        KEEP(*(.init))
        KEEP(*(.fini))
        . = ALIGN(4);
        _etext = .;
    } > FLASH

    .rodata : {
        . = ALIGN(4); 
        *(.rodata*) 
        . = ALIGN(4);
    } > FLASH 

    .ARM.extab : {
        *(.ARM.extab*)
    } > FLASH 

    .ARM.exidx : {
        *(.ARM.exidx*)
    } > FLASH 

    .preinit_array : {
        PROVIDE_HIDDEN(__preinit_array_start = .);
        KEEP(*(.preinit_array*));
        PROVIDE_HIDDEN(__preinit_array_end = .);
    } > FLASH

    .init_array : {
        PROVIDE_HIDDEN(__init_array_start = .);
        KEEP(*(SORT(.init_array.*)))
        KEEP(*(.init_array*)) 
        PROVIDE_HIDDEN(__init_array_end = .);
    } > FLASH 

    .fini_array : {
        PROVIDE_HIDDEN(__fini_array_start = .);
        KEEP(*(.fini_array*))
        KEEP(*(SORT(.fini_array.*)))
        PROVIDE_HIDDEN(__fini_array_end = .);
    } > FLASH 
   
    _sidata = .; 
    .data : AT(_sidata) {
        . = ALIGN(4);
        _sdata = .;
        *(.data) 
        *(.data*) 
        _edata = .;
        . = ALIGN(4);
    } > RAM 

    .bss : {
        _sbss = .; 
        __bss_start__ = _sbss; 
        *(.bss) 
        *(.bss*) 
        *(COMMON) 
        . = ALIGN(4);
        _ebss = .;
        __bss_end__ = _ebss;
    } > RAM
    
    /DISCARD/ : 
    {
        libc.a (*) 
        libm.a (*) 
        libgcc.a (*)
    }
    _stack_top = ORIGIN(RAM) + LENGTH(RAM);
}
