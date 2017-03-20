/* linker.ld */
/* Linker script for "hybrid" two-stage MBR boot-loader. */

/**
 * Our entry point is _start.
 * This will initialize the stack and errno,
 * as well as load our second stage boot-loader.
 */
ENTRY(_start)

/**
 * We will just be using one section, the .text section.
 */
SECTIONS
{
    /**
     * Our ELF will start at 0x7800 and our .text section at a 1k offset.
     * This way our .text section starts at 0x7c00 where it will be loaded by the BIOS.
     */
    . = 0x7800;
    .text BLOCK(1k) : ALIGN(1k)
    {
        /**
         * We're going to fill unused space with zeros, becuase they are easier to spot.
         */
        FILL(0x00);

        /**
         * Our stage one boot-loader will be packed in with our data.
         * This is just to help balance space for our stage two boot-loader.
         * The only thing in .text is global functions, including _start.
         */
        *(.text)
        *(.stage1)
        *(.data)
        *(.rodata)

        /**
         * This will create an error if we cannot fit our stage 1 boot-loader
         * in the space between the start of the sector and the DOS partition table.
         * NOTE: watch out for "cannot move position backwards (from ... to 0..07dbe)".
         */
        . = 0x1be;

        /**
         * The magic bytes for MBR boot-sector.
         */
        . = 0x1fe;
        SHORT(0xAA55)

        /**
         * Our stage two boot-loader will start at LBA 1.
         */
        . = 0x200;
        *(.stage2)

        /**
         * This will create an error if we cannot fit our stage 2 boot-loader in LBA 1.
         * It is also important that our boot-loader can fit before 0x8000, beccause
         * we will be loading our kernel at that address.
         * NOTE: watch out for "cannot move position backwards (from ... to 0..08000)".
         */
        . = 0x400;
    }
}

/* vim: se ts=4 sw=4 et syn=ld: */
