// generate_gdt.c

#include <stdio.h>
#include <stdbool.h>
#include <izixboot/gdt.h>
#include <izixboot/gdt32.h>

static gdt32_entry_t entries[3];

static const gdt32_logical_entry_t code_entry = {
	.base   = 0x00000000,
	.limit  = 0xfffff,
	.access = {
		.accessed             = GDT_UNACCESSED,
		.read_write           = GDT_CODE_RX,
		.direction_conforming = GDT_NONCONFORMING,
		.executable           = GDT_EXECUTABLE,
		.priviledge           = GDT_RING0,
		.present              = GDT_PRESENT
	},
	.flags  = {
		.size        = GDT_SIZE32,
		.granularity = GDT_GRANULARITY_PAGE
	}
};
static const gdt32_logical_entry_t data_entry = {
	.base   = 0x00000000,
	.limit  = 0xfffff,
	.access = {
		.accessed             = GDT_UNACCESSED,
		.read_write           = GDT_DATA_RW,
		.direction_conforming = GDT_DIRECTION_UP,
		.executable           = GDT_NONEXECUTABLE,
		.priviledge           = GDT_RING0,
		.present              = GDT_PRESENT
	},
	.flags  = {
		.size        = GDT_SIZE32,
		.granularity = GDT_GRANULARITY_PAGE
	}
};

int main () {
	entries[0] = gdt32_encode_blank ();
	entries[1] = gdt32_encode (code_entry);
	entries[2] = gdt32_encode (data_entry);

	puts (
		"// gdtproto.s\n"
		"\n"
		".file\t\t\"gdtproto.s\"\n"
		"");
	printf (
		"\t.set\tgdtlen,\t\t0x%04x\n", sizeof(entries));
	puts (
		"\n"
		".section\t.rodata\n"
		"\n"
		"\t.type\tgdtproto,\t@object\n"
		"gdtproto:\n"
		"\n"
		"\t.type\tgdtproto_null,\t@object\n"
		"gdtproto_null:");
	printf (
		"\t.long\t0x%08x\n", ((uint32_t *)(entries + 0))[0]);
	printf (
		"\t.long\t0x%08x\n", ((uint32_t *)(entries + 0))[1]);
	puts (
		"\t.size\tgdtproto_null,\t.-gdtproto_null\n"
		"\n"
		"\t.type\tgdtproto_code,\t@object\n"
		"gdtproto_code:");
	printf (
		"\t.long\t0x%08x\n", ((uint32_t *)(entries + 1))[0]);
	printf (
		"\t.long\t0x%08x\n", ((uint32_t *)(entries + 1))[1]);
	puts (
		"\t.size\tgdtproto_code,\t.-gdtproto_code\n"
		"\n"
		"\t.type\tgdtproto_data,\t@object\n"
		"gdtproto_data:");
	printf (
		"\t.long\t0x%08x\n", ((uint32_t *)(entries + 2))[0]);
	printf (
		"\t.long\t0x%08x\n", ((uint32_t *)(entries + 2))[1]);
	puts (
		"\t.size\tgdtproto_data,\t.-gdtproto_data\n"
		"\n"
		"\t.size\tgdtproto,\t.-gdtproto\n"
		"\n"
		"// vim: set ts=8 sw=8 noet syn=asm:");

	return 0;
}

// vim: set ts=4 sw=4 noet syn=c:
