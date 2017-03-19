#!/bin/bash
# write-boot-loader.sh
# Write the bootloader to the disk.

set -e

function usage() {
  echo "Usage: $1 <boot loader> <disk>."
}

if [[ 2 -ne $# ]]; then
  echo "This script requires exactly two arguments" >&2
  usage "$0"
  exit 2
fi

if [[ ! -f "$1" ]]; then
  echo "The first argument must be a file." >&2
  usage "$0"
  exit 2
fi

if [[ ! -f "$2" || -b "$2" ]]; then
  echo "The second argument must be a file or block device." >&2
  usage "$0"
  exit 2
fi

dd if="$1" of="$2" bs=446 count=1                   conv=notrunc status=none
dd if="$1" of="$2" bs=1   count=2 skip=510 seek=510 conv=notrunc status=none
dd if="$1" of="$2" bs=512 count=1 skip=1   seek=1   conv=notrunc status=none

echo "Wrote boot-loader successfuly." >&2

exit 0

# vim: set ts=2 sw=2 et syn=sh;
