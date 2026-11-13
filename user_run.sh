#!/bin/bash
set -xue    # 실행하는 명령을 출력하고, 실패하면 즉시 중단

# 툴체인 (GCC riscv64로 32비트 빌드)
CC=riscv64-unknown-elf-gcc
OBJCOPY=riscv64-unknown-elf-objcopy
QEMU=qemu-system-riscv32

CFLAGS="-std=c11 -O2 -g3 -Wall -Wextra \
        -march=rv32imac_zicsr -mabi=ilp32 \
        -ffreestanding -nostdlib -fno-stack-protector \
        -Wl,--no-warn-rwx-segments"

# 이전 빌드 산출물 정리
rm -f shell.elf shell.bin shell.bin.o kernel.elf

# Build the shell (application)
$CC $CFLAGS -Wl,-Tuser.ld -Wl,-Map=shell.map -o shell.elf shell.c user.c common.c
$OBJCOPY --set-section-flags .bss=alloc,contents -O binary shell.elf shell.bin
$OBJCOPY -Ibinary -Oelf32-littleriscv shell.bin shell.bin.o

# Build the kernel
$CC $CFLAGS -Wl,-Tkernel.ld -Wl,-Map=kernel.map -o kernel.elf \
    kernel.c common.c shell.bin.o

$QEMU -machine virt -bios default -nographic -serial mon:stdio --no-reboot \
    -kernel kernel.elf