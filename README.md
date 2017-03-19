<!-- READEME.md -->
# izixboot
Simple "hybrid" 2-stage MBR (+ LBA 1) boot-loader designed for the izix kernel (a work in progress).
izixboot reads a generic DOS partition table and looks for the first bootable partition.
Extended partitions are not supported as LBA 1 is occupied by the second stage boot-loader.
It will load up to `127` sectors for that partition into memory at `0x8000`, initialize the GDT with a flat memory model, switch to 32-bit protected mode, and then far jump to `0x9000`.
The stack will be initialized, but you should probably reinitialize it with something more appropriate for your kernel.
It should work fine with most 32-bit x86 kernel whose entry point is `0x9000` at a `0x1000` (4 KiB) offset from the start of the executable.

# Building:
Just run `make`.
This will create `boot.elf` and `boot`.
* `boot.elf` is the boot-loader as an ELF object, complete with GDB debugging symbols.
   This will not work for the MBR, but is convenient for debugging and inspection.
* `boot` is a two sector large raw binary boot-loader, which must be placed in LBA 0 and LBA 1 of your boot disk.
## Requirements:
* GNU Make >=4.x-ish.
* You will need a relatively recent >=4.x-ish GCC and >=2.x-ish binutils which can emit x86 code.
  Ensure that it's the first `gcc`, `ld`, and `as` in your path.

# Installing:
## Installing the boot-loader:
An installation script has been placed in `scripts/write-boot-loader.sh`.
To use it invoke it with the first argument being `boot`, the binary boot-loader, and the second argument being your disk file or block device.
This will not overwrite your primary DOS partition table, it will however overwrite your extended partition table, which is not compatible with izixboot.
## To installing your kernel for use with izixboot:
First, create a new DOS partition with the bootable flag set, it can be larger than `127` sectors, but only `127` sectors will be used.
Next, use `dd` to copy your kernel directly to the unformatted partition you just created.
That's it, you're good to go!

# Notes:
* If your kernel is not smaller than 63.5 KiB, it will not be loaded in entirety.
* If your kernel does not use `0x9000` as the entry point at a 4 KiB from the start of the executable, it will not execute correctly.
* No arguments will be passed to your kernel, but the GDTr will be located at `0x500`.

# License:

```
izixboot  --  Simple "hybrid" 2-stage MBR (+ LBA 1) boot-loader.
Copyright (C) 2017  Isabell Cowan

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
```
<!-- vim: set ts=2 sw=2 et syn=markdown: -->
