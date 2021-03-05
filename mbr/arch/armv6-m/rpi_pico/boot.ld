MEMORY {
    FLASH(rx) : ORIGIN = 0x10000100, LENGTH = 190 
    RAM(rwx)  : ORIGIN = 0x20041f00, LENGTH = 2K 
}

SECTIONS {
    . = ORIGIN(FLASH);
    .text : {
        *(.entry)
        *(.text)
    } > FLASH 
}
