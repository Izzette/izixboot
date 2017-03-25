/* linker.ld */
/* Linker script for "hybrid" two-stage MBR boot-loader. */

/**
 * Linker script for x86-bare-metal-examples MBR boot-loader.
 * Copyright (C) 2015 Ciro Santilli <http://www.cirosantilli.com/>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * Linker script for izixboot "hybrid" two-stage MBR boot-loader.
 * Copyright (C) 2017 Isabell Cowan <https://izzette.com/>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

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
     */
    . = 0x7800;

    /**
     * This will ensure that our text section starts at 0x7c00 where it will
     * be loaded by the BIOS.
     */
    . = 0x7c00;
    .text BLOCK(1k) : ALIGN(1k)
    {
        /**
         * We're going to fill unused space with zeros, becuase they are easier to spot.
         */
        FILL(0x00);

        /**
         * Our stage one boot-loader will be packed in with
         * our data and our 32-bit protected mode code.
         * This is just to help balance space for our stage two boot-loader.
         * The only thing in .text is global functions, including _start.
         */
        *(.text)
        *(.stage1)
        *(.pmode)
        *(.data)
        *(.rodata)

        /**
         * This will create an error if we cannot fit our stage 1 boot-loader
         * in the space between the start of the sector and the DOS partition table.
         * NOTE: watch out for "cannot move location counter backwards (from ... to 0..07dbe)".
         */
        . = 0x1be;

        /**
         * Here we create a DOS partition table entry that can optionally be used
         * with the boot-loader.  It creates a partition containing just LBA 1,
         * to protect the second stage boot-loader.
         */

        /* Not bootable. */
        BYTE(0x00)
        /* Starting head. */
        BYTE(0x00)
        /* Starting cylinder (0-indexed) and sector (1-indexed). */
        SHORT(0x0002)
        /* Non-FS data. */
        BYTE(0xda)
        /* Ending head. */
        BYTE(0x00)
        /* Ending cylinder and sector. */
        SHORT(0x0002)
        /* Starting LBA (0-indexed). */
        LONG(0x00000001)
        /* Sectors in parition. */
        LONG(0x00000001)

        /* Remaining partitions, empty, for good measure. */
        QUAD(0x0000000000000000) QUAD(0x0000000000000000)
        QUAD(0x0000000000000000) QUAD(0x0000000000000000)
        QUAD(0x0000000000000000) QUAD(0x0000000000000000)

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
         * NOTE: watch out for "cannot move location counter backwards (from ... to 0..08000)".
         */
        . = 0x400;
    }
}

/* vim: set ts=4 sw=4 et syn=ld: */
