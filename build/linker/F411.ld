
ENTRY(reset_)


MEMORY
{
   FLASH(RX) : ORIGIN = 0x08000000, LENGTH = 512K
   SRAM(XRW) : ORIGIN = 0x20000000, LENGTH = 128K
}
_estack = ORIGIN(SRAM) + LENGTH(SRAM);

SECTIONS
{
   .isr_vector :
   {
    . = ALIGN(4);
    KEEP(*(.isr_vector)) 
    . = ALIGN(4);
   } >FLASH

   .text : {
      . = ALIGN(4);
      *(.text)
      *(.text*)
      . = ALIGN(4);
   } > FLASH

   _sidata = LOADADDR(.data);
   .data :
   {
      . = ALIGN(4);
      _sdata = .;        
      *(.data)           
      *(.data*)          
      . = ALIGN(4);
      _edata = .;        

   } >SRAM AT> FLASH
   .bss  : 
   {
    _sbss = .;         
    __bss_start__ = _sbss;
    *(.bss)
    *(.bss*)
    . = ALIGN(4);
    _ebss = .;         
    __bss_end__ = _ebss;
    } > SRAM
}
