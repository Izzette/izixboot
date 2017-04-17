// gdt_recode.c

#include <stdio.h>
#include <izixboot/gdt.h>
#include <izixboot/gdt32.h>

static const gdt32_entry_t code_entry = 0x00cf9a000000ffff;
static const gdt32_entry_t data_entry = 0x00cf92000000ffff;

int main () {
	gdt32_logical_entry_t code_logical_entry, data_logical_entry;
	gdt32_entry_t recoded_code_entry, recoded_data_entry;

	gdt32_decode (code_entry, &code_logical_entry);
	gdt32_decode (data_entry, &data_logical_entry);

	recoded_code_entry = gdt32_encode (code_logical_entry);
	recoded_data_entry = gdt32_encode (data_logical_entry);

	if (code_entry != recoded_code_entry) {
		fputs ("GDT code entry changed after decode/encode!\n", stderr);
		fprintf (
			stderr,
			"Got 0x%016lx, expected 0x%016lx.\n",
			recoded_code_entry, code_entry);
		return 1;
	}
	if (data_entry != recoded_data_entry) {
		fputs ("GDT data entry changed after decode/encode!\n", stderr);
		fprintf (
			stderr,
			"Got 0x%016lx, expected 0x%016lx.\n",
			recoded_data_entry, data_entry);
		return 1;
	}

	return 0;
}

// vim: set ts=4 sw=4 noet syn=c:
