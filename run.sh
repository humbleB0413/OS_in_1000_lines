#!/bin/bash

set -xue
QEMU=qemu-system-riscv32

CC=riscv64-unknown-elf-gcc
CFLAGS="-std=c11 -O2 -g3 -Wall -Wextra \
  -march=rv32imac_zicsr_zifencei -mabi=ilp32 -mcmodel=medany \
  -fno-stack-protector -ffreestanding -nostdlib"

$CC $CFLAGS -Wl,-Tkernel.ld -Wl,-Map=kernel.map -o kernel.elf \
    kernel.c -lgcc

$QEMU -machine virt -bios default -nographic -serial mon:stdio --no-reboot \
    -kernel kernel.elf