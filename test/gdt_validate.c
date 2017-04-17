// gdt_validate.c

#include <stdio.h>
#include <izixboot/gdt.h>
#include <izixboot/gdt32.h>

static const gdt32_entry_t null_entry = 0x0000000000000000;
static const gdt32_entry_t code_entry = 0x00cf9a000000ffff;
static const gdt32_entry_t data_entry = 0x00cf92000000ffff;
static const gdt32_entry_t junk_entry = 0x0030000000000000;

int main() {
  if  (gdt32_validate (null_entry)) {
    fputs ("GDT validation succeeded on a null entry, it should not!", stderr);
    return 1;
  }
  if (!gdt32_validate (code_entry)) {
    fputs ("GDT validation failed on the valid code entry!", stderr);
    return 1;
  }
  if (!gdt32_validate (data_entry)) {
    fputs ("GDT validation failed on the valid data entry!", stderr);
    return 1;
  }
  if  (gdt32_validate (junk_entry)) {
    fputs ("GDT validation succeeded on a junk entry, it should not!", stderr);
    return 1;
  }

  return 0;
}

// vim: set ts=4 sw=4 noet syn=c:
