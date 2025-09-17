SRC_DIR		:= src

TARGET 		:= i386-unknown-none.json
RUST_SRC	:= $(shell find $(SRC_DIR)/rust -type f -name '*.rs')
ASM_SRC 	:= $(shell find $(SRC_DIR)/asm -type f -name '*.asm')

ASM_OBJ 	:= $(ASM_SRC:.asm=.o)
RUST_LIB	:= target/i386-unknown-none/release/libkfs.a

KERNEL_BIN  := kernel.bin
ISO_DIR     := iso
ISO_OUT     := kfs.iso

SHARED_DIR	:= /vagrant

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

%.o: %.asm
	nasm -f elf32 $< -o $@

$(RUST_LIB): $(RUST_SRC) Cargo.toml $(TARGET)
	cargo +nightly build --target $(TARGET) --release

# --- Link kernel -------------------------------------------------------------

$(KERNEL_BIN): $(ASM_OBJ) $(RUST_LIB) linker.ld
	# Link the assembled objects with the rust static library which
	# contains libcore and the panic implementation
	ld -m elf_i386 -T linker.ld -o $(KERNEL_BIN) $(ASM_OBJ) $(RUST_LIB)

# --- ISO with GRUB -----------------------------------------------------------

$(ISO_OUT): $(KERNEL_BIN) iso/boot/grub/grub.cfg Vagrantfile
	vagrant up
	vagrant ssh -c "cp $(SHARED_DIR)/$(KERNEL_BIN) $(SHARED_DIR)/$(ISO_DIR)/boot/kernel.bin"
	vagrant ssh -c "grub-mkrescue -o $(SHARED_DIR)/$(ISO_OUT) $(SHARED_DIR)/$(ISO_DIR)"
	vagrant halt
