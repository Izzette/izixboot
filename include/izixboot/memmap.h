// izixboot/memmap.h

/**
 * ACPI 3.x int 15h, eax=e820h memory map headers.
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

#ifndef _IZIXBOOT_MEMMAP_H
#define _IZIXBOOT_MEMMAP_H 1

#include <stdint.h>

// Types for struct e820_3x_entry.
typedef uint64_t e820_base_t;
typedef uint64_t e820_size_t;
typedef uint32_t e820_type_t;
typedef uint32_t e820_3x_xattrs_t;

// Memory region types (e820_type_t).
#define E820_TYPE_USABLE   0x1
#define E820_TYPE_RESERVED 0x2
#define E820_TYPE_RECLAIM  0x3
#define E820_TYPE_NVS      0x4
#define E820_TYPE_BAD      0x5

// ACPI 3.x extended attribute bitfield masks.
#define E820_3X_XATTRS_DO_NOT_IGNORE 0x1  // Ignore the entry if bit is clear.
#define E820_3X_XATTRS_NON_VOLITALE  0x2  // Region in non-volatile if bit is set.

// ACPI 3.x int 15h, eax=e820h entry.
typedef struct e820_3x_entry {
	e820_base_t      base;    // The base address of the region.
	e820_size_t      length;  // Length of the region.
	e820_type_t      type;    // The type of region.
                              // See E820_TYPE_* macros.
	e820_3x_xattrs_t xattrs;  // ACPI 3.x extended attributes bitfield.
                              // See E820_3X_XATTRS_* macros.
} e820_3x_entry_t;

#endif  // END <izixboot/memmap.h>

// vim: set ts=4 sw=4 noet syn=c:
