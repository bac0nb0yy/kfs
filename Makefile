NASM        := nasm
RUSTC       := rustc
LD          := ld
QEMU        := qemu-system-i386
GRUBMKRESCUE:= grub-mkrescue

TARGET 		:= i386-none
TARGET_JSON := $(TARGET).json

KERNEL_ELF  := kernel.elf
KERNEL_BIN  := kernel.bin
ISO_DIR     := iso
ISO_OUT     := kfs.iso

RUSTFLAGS := --target $(TARGET_JSON) \
	-C panic=abort -C opt-level=z -C lto -C relocation-model=static \
	-C link-arg=-nostdlib -C link-arg=-nodefaultlibs

# --- Top-level targets -------------------------------------------------------

all: $(KERNEL_BIN)

iso: $(ISO_OUT)

run: $(ISO_OUT)
	$(QEMU) -cdrom $(ISO_OUT)

clean:
	rm -rf *.o $(KERNEL_ELF) $(KERNEL_BIN) $(ISO_OUT)

fclean: clean
	rm -rf iso/boot/kernel.bin
	cargo clean

re: fclean all

# --- Build objects -----------------------------------------------------------

boot.o: src/boot.asm
	$(NASM) -f elf32 $< -o $@

main.o:
	cargo +nightly rustc --target $(TARGET_JSON) \
	    -Z build-std=core,compiler_builtins --release \
	    -- -C codegen-units=1 --emit=obj
	cp -f target/$(TARGET)/release/deps/kfs-*.o main.o

# --- Link kernel -------------------------------------------------------------

$(KERNEL_ELF): boot.o main.o linker.ld
	$(LD) -m elf_i386 -T linker.ld -o $(KERNEL_ELF) boot.o main.o

$(KERNEL_BIN): $(KERNEL_ELF)
	# For GRUB Multiboot, we can keep the ELF as "kernel.bin".
	# If you want a raw binary, you could objcopy, but GRUB expects an ELF w/ multiboot.
	objcopy $(KERNEL_ELF) $(KERNEL_BIN)
	@ls -lh $(KERNEL_BIN)

# --- ISO with GRUB -----------------------------------------------------------

$(ISO_OUT): $(KERNEL_BIN) iso/boot/grub/grub.cfg
	@mkdir -p $(ISO_DIR)/boot
	cp $(KERNEL_BIN) $(ISO_DIR)/boot/kernel.bin
	$(GRUBMKRESCUE) -o $(ISO_OUT) $(ISO_DIR)
	@ls -lh $(ISO_OUT)
