#!/bin/bash

dd if=boot of="$1" bs=446 count=1 conv=notrunc status=none

# vim: set ts=2 sw=2 et syn=sh;
