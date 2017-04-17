// gdtr_sizeof.c

#include <stdio.h>
#include <izixboot/gdt.h>
#include <izixboot/gdt32.h>

#define GDTR_EXPECTED_SIZE 6L

int main () {
	size_t sizeof_gdt_register;

	sizeof_gdt_register = sizeof(gdt_register_t);

	if (GDTR_EXPECTED_SIZE != sizeof_gdt_register) {
		fputs ("The type gdt_register_t was not the correct size!\n", stderr);
		fprintf (
			stderr,
			"Got %ld, expected %ld.\n",
			sizeof_gdt_register, GDTR_EXPECTED_SIZE);
		return 1;
	}

	return 0;
}

// vim: set ts=4 sw=4 noet syn=c:
