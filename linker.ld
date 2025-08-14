ENTRY(multiboot_entry)

SECTIONS
{
  /* GRUB loads at or above 1 MiB; place kernel there */
  . = 1M;

  .multiboot : {
    *(.multiboot)
  }

  .text : ALIGN(4K) {
    *(.text*)
  }

  .rodata : ALIGN(4K) {
    *(.rodata*)
  }

  .data : ALIGN(4K) {
    *(.data*)
  }

  .bss : ALIGN(4K) {
    *(.bss*)
    *(COMMON)
  }
}
