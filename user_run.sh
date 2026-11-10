#!/bin/bash
set -xue

# GNU RISC-V 크로스 툴체인 (설치된 prefix에 맞게 수정)
PREFIX=riscv64-unknown-elf-
CC=${PREFIX}gcc
OBJCOPY=${PREFIX}objcopy

CFLAGS="-std=c11 -O2 -g3 -Wall -Wextra \
  -march=rv32imac_zicsr_zifencei -mabi=ilp32 \
  -fno-stack-protector -ffreestanding -nostdlib -fno-builtin" 

# Build the shell (application)
$CC $CFLAGS -Wl,-Tuser.ld -Wl,-Map=shell.map -o shell.elf shell.c user.c common.c -lgcc
$OBJCOPY --set-section-flags .bss=alloc,contents -O binary shell.elf shell.bin
$OBJCOPY -I binary -O elf32-littleriscv -B riscv shell.bin shell.bin.o

# Build the kernel
$CC $CFLAGS -Wl,-Tkernel.ld -Wl,-Map=kernel.map -o kernel.elf \
    kernel.c common.c shell.bin.o -lgcc