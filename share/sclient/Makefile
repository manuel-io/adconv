NAME        := sclient
VERSION     := v1.0
RATE        := 9600
OPTIMIZE    := -Os
WARNINGS    := -Wall
CC          := gcc
LD          := gcc
CFLAGS      := -std=c99 $(OPTIMIZE) $(WARNINGS)
LDFLAGS     := -Wl,-Map,$(NAME).map

.PHONY: clean

all: $(NAME)
	$(info $(VERSION))

%.o: %.c
	$(CC) -c $(CFLAGS) $<

$(NAME): main.o
	$(LD) $(CFLAGS) $(LDFLAGS) -o $@ $+

clean:
	rm -rf $(NAME) *.elf *.d *.o *.hex *.bin *.map

