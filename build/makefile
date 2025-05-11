INC_DIR := include
SRC_DIR := source
BUILD_DIR := build

SRCS_C := $(shell find $(SRC_DIR) -type f -name "*.c")
SRCS_ASM := $(shell find $(SRC_DIR) -type f -name "*.s")
HEADERS := $(shell find $(INC_DIR) -type f -name "*.h")

OBJS := $(SRCS_C:.c=.o) $(SRCS_ASM:.s=.o) 

EXEC := RDX_boot.bin RDX_operational.bin RDX_iap.bin

CC := clang

CFLAGS := -Wall -Wextra -Werror -pedantic -O0 -I$(INC) \
          -Waddress -Warray-bounds -Wcast-align -Wconversion \
          -Wfloat-equal -Wformat -Wimplicit-function-declaration \
          -Wmissing-prototypes -Wnull-dereference -Wshadow \
          -Wsign-compare -Wstrict-aliasing -Wuninitialized \
          -Wunused-variable 


all: $(OBJS)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@ -I $(INC_DIR)


clean:
	rm -f $(BUILD_DIR)/*.o $(BUILD_DIR)/*.elf


CRUST := $(patsubst $(SRC_DIR)/%.c, $(SRC_DIR)/%.uncrustify, $(SRCS))
CRUST += $(patsubst $(INC_DIR)/%.h, $(INC_DIR)/%.uncrustify, $(HEADERS))

uncrustify: $(CRUST)
$(eval $(SRC_DIR)/%.uncrustify: $(SRC_DIR)/%.c; uncrustify -c .uncrustify.cfg -f $$< > $$@)
$(eval $(INC_DIR)/%.uncrustify: $(INC_DIR)/%.h; uncrustify -c .uncrustify.cfg -f $$< > $$@)

cppcheck:
	cppcheck --force -q  --check-level=exhaustive --enable=all $(SRCS) $(HEADERS) -I $(INC_DIR) --checkers-report=cppcheck_report.xml 

.PHONY: all clean uncrustify cppcheck
