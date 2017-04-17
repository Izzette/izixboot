// izixboot/gdt.h

/**
 * GDT data-structures for 32-bit and 64-bit systems.
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

#ifndef _IZIXBOOT_GDT_H
#define _IZIXBOOT_GDT_H 1

#include <stdint.h>
#include <stdbool.h>

// Offsets for values in bits.
#define GDT_LIMIT_LOW_OFFSET  0000
#define GDT_BASE_LOW_OFFSET   0020
#define GDT_ACCESS_OFFSET     0050
#define GDT_LIMIT_HIGH_OFFSET 0060
#define GDT_FLAGS_OFFSET      0064
#define GDT_BASE_HIGH_OFFSET  0070

// Lengths for values in bits.
#define GDT_LENGTH 0100
#define GDT_LIMIT_LOW_LENGTH \
	(GDT_BASE_LOW_OFFSET   - GDT_LIMIT_LOW_OFFSET)
#define GDT_BASE_LOW_LENGTH \
	(GDT_ACCESS_OFFSET     - GDT_BASE_LOW_OFFSET)
#define GDT_ACCESS_LENGTH \
	(GDT_LIMIT_HIGH_OFFSET - GDT_ACCESS_OFFSET)
#define GDT_LIMIT_HIGH_LENGTH \
	(GDT_FLAGS_OFFSET      - GDT_LIMIT_HIGH_OFFSET)
#define GDT_FLAGS_LENGTH \
	(GDT_BASE_HIGH_OFFSET  - GDT_FLAGS_OFFSET)
#define GDT_BASE_HIGH_LENGTH \
	(GDT_LENGTH            - GDT_BASE_HIGH_OFFSET)

// Lengths for low and high fields combined;
#define GDT_LIMIT_LENGTH \
	(GDT_LIMIT_LOW_LENGTH + GDT_LIMIT_HIGH_LENGTH)
#define GDT_BASE_LENGTH \
	(GDT_BASE_LOW_LENGTH  + GDT_BASE_HIGH_LENGTH)

// Bitmasks for converting from logical values.
#define GDT_LIMIT_LOW_BITMASK \
	(((0x00000001 << GDT_LIMIT_LOW_LENGTH)  - 1))
#define GDT_LIMIT_HIGH_BITMASK \
	(((0x00000001 << GDT_LIMIT_HIGH_LENGTH) - 1) << GDT_LIMIT_LOW_LENGTH)
#define GDT_BASE_LOW_BITMASK \
	(((0x00000001 << GDT_BASE_LOW_LENGTH)   - 1))
#define GDT_BASE_HIGH_BITMASK \
	(((0x00000001 << GDT_BASE_HIGH_LENGTH)  - 1) << GDT_BASE_LOW_LENGTH)

// Bitmasks for converting to logical values.
#define GDT_LIMIT_LOW_DEMASK \
	(((0x00000001L << GDT_LIMIT_LOW_LENGTH)  - 1) << GDT_LIMIT_LOW_OFFSET)
#define GDT_LIMIT_HIGH_DEMASK \
	(((0x00000001L << GDT_LIMIT_HIGH_LENGTH) - 1) << GDT_LIMIT_HIGH_OFFSET)
#define GDT_BASE_LOW_DEMASK \
	(((0x00000001L << GDT_BASE_LOW_LENGTH)   - 1) << GDT_BASE_LOW_OFFSET)
#define GDT_BASE_HIGH_DEMASK \
	(((0x00000001L << GDT_BASE_HIGH_LENGTH)  - 1) << GDT_BASE_HIGH_OFFSET)
#define GDT_ACCESS_DEMASK \
	(((0x00000001L << GDT_ACCESS_LENGTH)     - 1) << GDT_ACCESS_OFFSET)
#define GDT_FLAGS_DEMASK \
	(((0x00000001L << GDT_FLAGS_LENGTH)      - 1) << GDT_FLAGS_OFFSET)

/* Access Byte Legend:
 * AC = Accessed bit.
 * RW = Read/write bit.
 * DC = Direction/Conforming bit.
 * EX = Executable bit.
 * AM = Access magic bit (always 0b1).
 * PV = Privledge bits (two of them).
 * PR = Present bit.
 */

// Offsets for access byte bitfield in bits.
#define GDT_ACCESS_AC_OFFSET 000
#define GDT_ACCESS_RW_OFFSET 001
#define GDT_ACCESS_DC_OFFSET 002
#define GDT_ACCESS_EX_OFFSET 003
#define GDT_ACCESS_AM_OFFSET 004
#define GDT_ACCESS_PV_OFFSET 005
#define GDT_ACCESS_PR_OFFSET 007

// Lengths for access byte bitfield in bits.
#define GDT_ACCESS_AC_LENGTH \
	(GDT_ACCESS_RW_OFFSET - GDT_ACCESS_AC_OFFSET)
#define GDT_ACCESS_RW_LENGTH \
	(GDT_ACCESS_DC_OFFSET - GDT_ACCESS_RW_OFFSET)
#define GDT_ACCESS_DC_LENGTH \
	(GDT_ACCESS_EX_OFFSET - GDT_ACCESS_DC_OFFSET)
#define GDT_ACCESS_EX_LENGTH \
	(GDT_ACCESS_AM_OFFSET - GDT_ACCESS_EX_OFFSET)
#define GDT_ACCESS_AM_LENGTH \
	(GDT_ACCESS_PV_OFFSET - GDT_ACCESS_AM_OFFSET)
#define GDT_ACCESS_PV_LENGTH \
	(GDT_ACCESS_PR_OFFSET - GDT_ACCESS_PV_OFFSET)
#define GDT_ACCESS_PR_LENGTH \
	(GDT_ACCESS_LENGTH    - GDT_ACCESS_PR_OFFSET)

/* Flags Legend:
 * FM = Flags magic bits (two of them, always 0b00).
 * L8 = x86-64 descriptor bit.
 * SZ = Size bit.
 * GR = Granularity bit.
 */

// Offsets for flags bitfield in bits.
#define GDT32_FLAGS_FM_OFFSET 00
#define GDT64_FLAGS_FM_OFFSET 00
#define GDT64_FLAGS_L8_OFFSET 01
#define GDT_FLAGS_SZ_OFFSET   02
#define GDT_FLAGS_GR_OFFSET   03

// Lengths for flags bitfield in bits.
#define GDT32_FLAGS_FM_LENGTH \
	(GDT_FLAGS_SZ_OFFSET   - GDT32_FLAGS_FM_OFFSET)
#define GDT64_FLAGS_FM_LENGTH \
	(GDT64_FLAGS_L8_OFFSET - GDT64_FLAGS_FM_OFFSET)
#define GDT64_FLAGS_L8_LENGTH \
	(GDT_FLAGS_SZ_OFFSET   - GDT64_FLAGS_L8_OFFSET)
#define GDT_FLAGS_SZ_LENGTH \
	(GDT_FLAGS_GR_OFFSET   - GDT_FLAGS_SZ_OFFSET)
#define GDT_FLAGS_GR_LENGTH \
	(GDT_FLAGS_LENGTH      - GDT_FLAGS_GR_OFFSET)

// Some typedefs.

typedef bool     gdt_bool;
typedef uint8_t  gdt_ring_t;
typedef bool     gdt_rw_t;
typedef bool     gdt_dc_t;
typedef bool     gdt_width_t;
typedef bool     gdt_block_t;
typedef uint32_t gdt_limit_t;
typedef uint32_t gdt_base_t;

// Some definitions for readability.

#define GDT_PRESENT true
#define GDT_ABSENT  false

#define GDT_RING0 0b00u
#define GDT_RING1 0b01U
#define GDT_RING2 0b10u
#define GDT_RING3 0b11u

#define GDT_DATA_RW    true
#define GDT_DATA_RONLY false
#define GDT_CODE_RX    true
#define GDT_CODE_XONLY false

#define GDT_DIRECTION_UP   false
#define GDT_DIRECTION_DOWN true

#define GDT_CONFORMING    true
#define GDT_NONCONFORMING false

#define GDT_EXECUTABLE    true
#define GDT_NONEXECUTABLE false

#define GDT_ACCESSED   true
#define GDT_UNACCESSED false

#define GDT_GRANULARITY_BYTE false
#define GDT_GRANULARITY_PAGE true

#define GDT_SIZE16 false
#define GDT_SIZE32 true

// Logical structures.

typedef struct gdt_logical_access {
	gdt_bool   accessed;
	gdt_rw_t   read_write;
	gdt_dc_t   direction_conforming;
	gdt_bool   executable;
	gdt_ring_t priviledge : GDT_ACCESS_PV_LENGTH;
	gdt_bool   present;
} gdt_logical_access_t ;

// Real entry type.
typedef uint8_t gdt_access_t;

// Inline functions to generate real valid entries.

static inline gdt_access_t gdt_access_encode (const gdt_logical_access_t logical_access) {
	gdt_access_t access =
		((logical_access.accessed             ? 0b1 : 0b0) << GDT_ACCESS_AC_OFFSET) |
		((logical_access.read_write           ? 0b1 : 0b0) << GDT_ACCESS_RW_OFFSET) |
		((logical_access.direction_conforming ? 0b1 : 0b0) << GDT_ACCESS_DC_OFFSET) |
		((logical_access.executable           ? 0b1 : 0b0) << GDT_ACCESS_EX_OFFSET) |
		(                                      (0b1)       << GDT_ACCESS_AM_OFFSET) |
		((logical_access.priviledge)                       << GDT_ACCESS_PV_OFFSET) |
		((logical_access.present              ? 0b1 : 0b0) << GDT_ACCESS_PR_OFFSET);

	return access;
}

static inline void gdt_access_decode (
		const gdt_access_t access,
		gdt_logical_access_t *logical_access
) {
	logical_access->accessed             =
		((access & (0b1  << GDT_ACCESS_AC_OFFSET)) ? true : false);
	logical_access->read_write           =
		((access & (0b1  << GDT_ACCESS_RW_OFFSET)) ? true : false);
	logical_access->direction_conforming =
		((access & (0b1  << GDT_ACCESS_DC_OFFSET)) ? true : false);
	logical_access->executable           =
		((access & (0b1  << GDT_ACCESS_EX_OFFSET)) ? true : false);
	logical_access->priviledge           =
		((access & (0b11 << GDT_ACCESS_PV_OFFSET)) >> GDT_ACCESS_PV_OFFSET);
	logical_access->present              =
		((access & (0b1  << GDT_ACCESS_PR_OFFSET)) ? true : false);
}

static inline bool gdt_access_validate (const gdt_access_t access) {
	return ((access & (0b1 << GDT_ACCESS_AM_LENGTH)) ? true : false);
}

#endif

// vim: set ts=4 sw=4 noet syn=c:
