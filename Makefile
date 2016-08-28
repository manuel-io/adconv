NAME        := adconv
DEV         := /dev/ttyACM0
RATE        := 115200
MCU         := m8
MCU_TARGET  := atmega8
MCU_CC      := avr-gcc
OPTIMIZE    := -Os
WARNINGS    := -Wall
DEFS        := -DF_CPU=8000000 -DV2
CFLAGS      := -std=c99 -MMD -g -mmcu=$(MCU_TARGET) $(OPTIMIZE) $(WARNINGS) $(DEFS)
ASFLAGS     := -g $(DEFS) -mmcu=$(MCU_TARGET)
LDFLAGS     := -Wl,-Map,$(NAME).map

OBJCOPY     := avr-objcopy
OBJDUMP     := avr-objdump
FLASHUSBCMD := avrdude -V -c usbasp -p $(MCU) -U lfuse:w:0xe4:m -U flash:w:$(NAME).hex

.PHONY: clean dispatch

all: $(NAME).hex $(NAME).bin

dispatch: $(NAME).hex
	$(FLASHUSBCMD)

%.o: %.c
	$(MCU_CC) -c $(CFLAGS) $<

%.o: %.S
	$(MCU_CC) $(ASFLAGS) -c $<

%.hex: %.elf
	$(OBJCOPY) -j .text -j .data -O ihex $< $@

%.bin: %.elf
	$(OBJCOPY) -j .text -j .data -O binary $< $@

$(NAME).elf: main.o hd44780.o dht11.o adc.o
	$(MCU_CC) $(CFLAGS) $(LDFLAGS) -o $@ $+

clean:
	rm -rf $(NAME) *.elf *.d *.o *.hex *.bin *.map

