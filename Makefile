TARGET 		:= i386-unknown-none.json
SRC			:= $(shell find src -type f -name '*.rs')

KERNEL_BIN  := kernel.bin
ISO_DIR     := iso
ISO_OUT     := kfs.iso

SHARED_DIR	:= /vagrant

RUSTFLAGS := --target $(TARGET) \
	-Z build-std=core,compiler_builtins --release -- \
	-C codegen-units=1 --emit=obj=main.o

# --- Top-level targets -------------------------------------------------------

all: $(KERNEL_BIN)

iso: $(ISO_OUT)

run: $(ISO_OUT)
	kvm -cpu host -cdrom $(ISO_OUT)

clean:
	rm -rf *.o $(KERNEL_BIN) $(ISO_OUT)

fclean: clean
	rm -rf iso/boot/kernel.bin
	cargo clean
	vagrant destroy --force

re: fclean all

# --- Build objects -----------------------------------------------------------

boot.o: src/boot.asm
	nasm -f elf32 $< -o $@

main.o: $(SRC) Cargo.toml $(TARGET)
	cargo +nightly rustc $(RUSTFLAGS)

# --- Link kernel -------------------------------------------------------------

$(KERNEL_BIN): boot.o main.o linker.ld
	ld -m elf_i386 -T linker.ld -o $(KERNEL_BIN) boot.o main.o

# --- ISO with GRUB -----------------------------------------------------------

$(ISO_OUT): $(KERNEL_BIN) iso/boot/grub/grub.cfg Vagrantfile
	vagrant up
	vagrant ssh -c "cp $(SHARED_DIR)/$(KERNEL_BIN) $(SHARED_DIR)/$(ISO_DIR)/boot/kernel.bin"
	vagrant ssh -c "grub-mkrescue -o $(SHARED_DIR)/$(ISO_OUT) $(SHARED_DIR)/$(ISO_DIR)"
	vagrant halt
