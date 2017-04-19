// gdtr_recode.c

#include <stdio.h>
#include <izixboot/gdt.h>
#include <izixboot/gdt32.h>

static gdt32_entry_t gdt[3];

int main () {
	gdt_register_t registry;
	gdt32_logical_register_t logical_registry, recoded_logical_registry;

	logical_registry.size = sizeof(gdt) / sizeof(gdt32_entry_t);
	logical_registry.offset = gdt;

	registry = gdt32_register_encode (logical_registry);
	gdt32_register_decode (registry, &recoded_logical_registry);

	if (logical_registry.size != recoded_logical_registry.size) {
		fputs ("GDT registry size changed after encode/decode!\n", stderr);
		fprintf (
			stderr,
			"Got 0x%04x, expected 0x%04x.\n",
			recoded_logical_registry.size, logical_registry.size);
		return 1;
	}
	if (logical_registry.offset != recoded_logical_registry.offset) {
		fputs ("GDT registry offset changed after encode/decode!\n", stderr);
#pragma GCC diagnostic ignored "-Wpointer-to-int-cast"
		fprintf (
			stderr,
			"Got 0x%08lx, expected 0x%08lx.\n",
			(uint64_t)recoded_logical_registry.offset, (uint64_t)logical_registry.offset);
#pragma GCC diagnostic pop
		return 1;
	}

	return 0;
}

// vim: set ts=4 sw=4 noet syn=c:
