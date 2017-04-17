// gdt_recode.c

#include <assert.h>
#include <izixboot/gdt.h>
#include <izixboot/gdt32.h>

static const gdt32_entry_t code_entry = 0x00cf9a000000ffffL;
static const gdt32_entry_t data_entry = 0x00cf92000000ffffL;

int main () {
	gdt32_logical_entry_t code_logical_entry, data_logical_entry;

	gdt32_decode (code_entry, &code_logical_entry);
	gdt32_decode (data_entry, &data_logical_entry);

	assert (code_entry == gdt32_encode (code_logical_entry));
	assert (data_entry == gdt32_encode (data_logical_entry));

	return 0;
}

// vim: set ts=4 sw=4 noet syn=c:
