// izixboot/gdt32.h

/**
 * IA32 GDT data-structures and generation inline-function headers.
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

#ifndef _IZIXBOOT_GDT32_H
#define _IZIXBOOT_GDT32_H 1

#include <stdint.h>
#include <stdbool.h>
#include <izixboot/gdt.h>

// Logical structures.

typedef struct gdt32_logical_flags {
	gdt_width_t size;
	gdt_block_t granularity;
} gdt32_logical_flags_t;

typedef struct gdt32_logical_entry {
	gdt_limit_t           limit : GDT_LIMIT_LENGTH;
	gdt_base_t            base  : GDT_BASE_LENGTH;
	gdt_logical_access_t  access;
	gdt32_logical_flags_t flags;
} gdt32_logical_entry_t;

// Real entry type.
typedef uint8_t  gdt32_flags_t;  // Actually restricted to 4 bits.
typedef uint64_t gdt32_entry_t;

// Inline functions to generate real valid entries.

static inline gdt32_entry_t gdt32_encode_blank () {
	return 0;
}

static inline gdt32_flags_t gdt32_flags_encode (const gdt32_logical_flags_t logical_flags) {
	gdt32_flags_t flags =
		(((gdt32_flags_t)                                  (0b00)) << GDT32_FLAGS_FM_OFFSET) |
		(((gdt32_flags_t)(logical_flags.size        ? 0b1 : 0b0))  << GDT_FLAGS_SZ_OFFSET)   |
		(((gdt32_flags_t)(logical_flags.granularity ? 0b1 : 0b0))  << GDT_FLAGS_GR_OFFSET);

	return flags;
}

static inline gdt32_entry_t gdt32_encode (const gdt32_logical_entry_t logical_entry) {
	gdt_access_t  access = gdt_access_encode (logical_entry.access);
	gdt32_flags_t flags  = gdt32_flags_encode (logical_entry.flags);

	gdt32_entry_t entry =
		(((gdt32_entry_t)(logical_entry.limit  & GDT_LIMIT_LOW_BITMASK))  << (GDT_LIMIT_LOW_OFFSET))                         |
		(((gdt32_entry_t)(logical_entry.base   & GDT_BASE_LOW_BITMASK))   << (GDT_BASE_LOW_OFFSET))                          |
		(((gdt32_entry_t)(access))                                        << (GDT_ACCESS_OFFSET))                            |
		(((gdt32_entry_t)(logical_entry.limit  & GDT_LIMIT_HIGH_BITMASK)) << (GDT_LIMIT_HIGH_OFFSET - GDT_LIMIT_LOW_LENGTH)) |
		(((gdt32_entry_t)(flags))                                         << (GDT_FLAGS_OFFSET))                             |
		(((gdt32_entry_t)(logical_entry.base   & GDT_BASE_HIGH_BITMASK))  << (GDT_BASE_HIGH_OFFSET - GDT_LIMIT_LOW_LENGTH));

	return entry;
}

static inline void gdt32_flags_decode (
		const gdt32_flags_t flags,
		gdt32_logical_flags_t *logical_flags
) {
	logical_flags->size        =
		((flags & (0b1 << GDT_FLAGS_SZ_OFFSET)) ? true : false);
	logical_flags->granularity =
		((flags & (0b1 << GDT_FLAGS_GR_OFFSET)) ? true : false);
}

static inline void gdt32_decode (const gdt32_entry_t entry, gdt32_logical_entry_t *logical_entry) {
	gdt_logical_access_t  logical_access;
	gdt32_logical_flags_t logical_flags;

	gdt_access_decode ((entry & GDT_ACCESS_DEMASK) >> GDT_ACCESS_OFFSET, &logical_access);
	gdt32_flags_decode ((entry & GDT_FLAGS_DEMASK) >> GDT_FLAGS_OFFSET, &logical_flags);

	logical_entry->limit  = (
		((entry & GDT_LIMIT_LOW_DEMASK)  >> (GDT_LIMIT_LOW_OFFSET)) |
		((entry & GDT_LIMIT_HIGH_DEMASK) >> (GDT_LIMIT_HIGH_OFFSET - GDT_LIMIT_LOW_LENGTH)));
	logical_entry->base   = (
		((entry & GDT_BASE_LOW_DEMASK)   >> (GDT_BASE_LOW_OFFSET))  |
		((entry & GDT_BASE_HIGH_DEMASK)  >> (GDT_BASE_HIGH_OFFSET - GDT_BASE_LOW_LENGTH)));
	logical_entry->access = logical_access;
	logical_entry->flags  = logical_flags;
}

#endif

// vim: set ts=4 sw=4 noet syn=c: