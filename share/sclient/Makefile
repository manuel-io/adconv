NAME     := sclient
VERSION  := v1.0
OPTIMIZE := -Os
WARNINGS := -Wall
CC       := gcc -c
LD       := gcc
CFLAGS   := -std=c99 $(OPTIMIZE) $(WARNINGS)
LDFLAGS  := -Wl,-Map,$(NAME).map

.PHONY: clean

all: $(NAME)
	$(info $(NAME) $(VERSION))

%.o: %.c
	$(CC) $(CFLAGS) $<

$(NAME): main.o
	$(LD) $(LDFLAGS) -o $@ $+

clean:
	rm -rf $(NAME) *.elf *.d *.o *.hex *.bin *.map

.PHONY: clean
