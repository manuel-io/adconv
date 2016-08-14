#ifndef CONFIG_H
#define CONFIG_H

#define LDR_CHANNEL 0

#define LCD_PORT PORTB
#define LCD_DDR  DDRB
#define LCD_R    PB0
#define LCD_E    PB1

#define DHT_OUTPUT PORTB
#define DHT_INPUT PINB
#define DHT_DDR DDRB
#define DHT_PIN PB7

#define FC28_OUTPUT PORTC
#define FC28_INPUT PINC
#define FC28_DDR DDRC
#define FC28_PIN PC0

#define STATUS_LED_ON DDRB |= (1 << PB6); \
                      PORTB |= (1 << PB6)

#define STATUS_LED_BLINK DDRB |= (1 << PB6); \
                         PORTB |= (1 << PB6); \
                         _delay_ms(500); \
                         PORTB &= ~(1 << PB6); \
                         _delay_ms(500); \
                         PORTB |= (1 << PB6); \
                         _delay_ms(500); \
                         PORTB &= ~(1 << PB6);

#define STATUS_LED_OFF PORTB &= ~(1 << PB6)

#endif /* CONFIG_H */
