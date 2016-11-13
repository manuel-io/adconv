NAME        := adconv
VERSION     := v2.0
MCU         := m8
DEFS        := -DF_CPU=16000000 -DV2
DEV         := /dev/ttyACM0
RATE        := 115200
MCU_TARGET  := atmega8
MCU_CC      := avr-gcc
OPTIMIZE    := -Os
WARNINGS    := -Wall
CFLAGS      := -std=c99 -MMD -g -mmcu=$(MCU_TARGET) $(OPTIMIZE) $(WARNINGS) $(DEFS)
ASFLAGS     := -g $(DEFS) -mmcu=$(MCU_TARGET)
LDFLAGS     := -Wl,-Map,$(NAME).map
OBJCOPY     := avr-objcopy
OBJDUMP     := avr-objdump
FLASHCMD    := avrdude -V -c usbasp -p $(MCU) -U lfuse:w:0x9f:m -U hfuse:w:0xc9:m -U flash:w:$(NAME).hex

.PHONY: clean dispatch

all: $(NAME).hex $(NAME).bin sclient
	$(info $(NAME) $(VERSION))

dispatch: $(NAME).hex
	$(FLASHCMD)

sclient:
	$(MAKE) -C share/sclient all

%.o: %.c
	$(MCU_CC) -c $(CFLAGS) $<

%.o: %.S
	$(MCU_CC) $(ASFLAGS) -c $<

%.hex: %.elf
	$(OBJCOPY) -j .text -j .data -O ihex $< $@

%.bin: %.elf
	$(OBJCOPY) -j .text -j .data -O binary $< $@

$(NAME).elf: main.o hd44780.o dht11.o adc.o uart.o
	$(MCU_CC) $(CFLAGS) $(LDFLAGS) -o $@ $+

clean:
	$(MAKE) -C share/sclient clean
	rm -rf $(NAME) *.elf *.d *.o *.hex *.bin *.map

