# === Paths ===
CODE_DIR := ../code
INC_DIR := ../include
BUILD_DIR := .
OBJ_DIR := $(BUILD_DIR)/objects
IMAGE_DIR := $(BUILD_DIR)/images

LINKER_DESCRIPTOR := $(BUILD_DIR)/linker/F411.ld

# === Toolchain ===
CC := clang
LD := ld.lld
OBJCOPY := llvm-objcopy
OBJDUMP := llvm-objdump
GDB := arm-none-eabi-gdb

# === Target names ===
EXEC := RDX
ELF := $(IMAGE_DIR)/$(EXEC).elf
BIN := $(IMAGE_DIR)/$(EXEC).bin
DUMP := $(IMAGE_DIR)/$(EXEC).dump
MAP := $(IMAGE_DIR)/$(EXEC).map

# === Find sources ===
SRCS_C := $(shell find $(CODE_DIR) -name "*.c")
SRCS_S := $(shell find $(CODE_DIR) -name "*.S")

# === Generate object files in OBJ_DIR (mirroring src paths)
OBJS := $(patsubst $(CODE_DIR)/%.c,$(OBJ_DIR)/%.o,$(SRCS_C))
OBJS += $(patsubst $(CODE_DIR)/%.S,$(OBJ_DIR)/%.o,$(SRCS_S))

# === Compiler and Linker Flags ===
CFLAGS := -Wall -Wextra -Werror \
          -target arm-none-eabi -mcpu=cortex-m4 -mthumb \
          -nostdlib -I$(CODE_DIR) -I$(INC_DIR) \
          -Waddress -Warray-bounds -Wcast-align -Wconversion \
          -Wfloat-equal -Wformat -Wimplicit-function-declaration \
          -Wmissing-prototypes -Wnull-dereference -Wshadow \
          -Wsign-compare -Wstrict-aliasing -Wuninitialized \
          -Wunused-variable -g

LDFLAGS := -T $(LINKER_DESCRIPTOR) -nostdlib -Map=$(MAP)

# === Rules ===

all: $(ELF) $(BIN) $(DUMP)

$(ELF): $(OBJS)
	@mkdir -p $(dir $@)
	$(LD) $(LDFLAGS) -o $@ $^

$(BIN): $(ELF)
	@mkdir -p $(dir $@)
	$(OBJCOPY) -O binary $< $@

$(DUMP): $(ELF)
	@mkdir -p $(dir $@)
	$(OBJDUMP) -d $< > $@

# Compile C sources
$(OBJ_DIR)/%.o: $(CODE_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

# Compile ASM sources
$(OBJ_DIR)/%.o: $(CODE_DIR)/%.S
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

# === OpenOCD Configuration ===
OCDCFG := -f /usr/share/openocd/scripts/interface/stlink.cfg \
          -f /usr/share/openocd/scripts/target/stm32f4x.cfg 

# === Flash via OpenOCD ===
flash: $(ELF)
	openocd $(OCDCFG) -c "program $(ELF) verify reset exit"

flash_bin: $(BIN)
	openocd $(OCDCFG) -c "program $(BIN) 0x08000000 verify reset exit"

# === GDB Debug ===
debug:
	openocd $(OCDCFG)

gdb:
	$(GDB) --eval-command="target remote localhost:3333" $(ELF)

gdbtui:
	$(GDB) -tui --eval-command="target remote localhost:3333" $(ELF)


# === Static Analysis ===
HEADERS := $(shell find $(CODE_DIR) -type f -name "*.h")

cppcheck:
	cppcheck --force -q --check-level=exhaustive --enable=all $(SRCS_C) $(HEADERS) -I$(CODE_DIR) --xml 2> cppcheck_report.xml

# === Code formatting with uncrustify ===
CRUST := $(patsubst ../%, ../%.uncrustify, $(SRCS_C)) \
         $(patsubst ../%, ../%.uncrustify, $(HEADERS))

uncrustify: $(CRUST)

../%.uncrustify: ../%.c
	uncrustify -c ../.uncrustify.cfg -f $< > $@

../%.uncrustify: ../%.h
	uncrustify -c ../.uncrustify.cfg -f $< > $@

# === Clean ===
clean:
	rm -rf $(IMAGE_DIR) $(OBJ_DIR)

.PHONY: all clean flash flash_bin gdb gdbtui uncrustify cppcheck debug
