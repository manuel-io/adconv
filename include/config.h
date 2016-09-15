#ifndef CONFIG_H
#define CONFIG_H

#define LCD_PORT PORTB
#define LCD_DDR  DDRB
#define LCD_R    PB0
#define LCD_E    PB1

#define LDR_CHANNEL PC2
#define FC28_CHANNEL PC3

#ifdef V2
#define LED_OUTPUT PORTD
#define LED_INPUT PIND
#define LED_DDR DDRD
#define LED_PIN PD6

#define DHT_OUTPUT PORTD
#define DHT_INPUT PIND
#define DHT_DDR DDRD
#define DHT_PIN PD7

/* 16.000MHz */
#define USART_BAUDRATE 0x67
#endif /* V2 */

#ifndef LED_OUTPUT
#define LED_OUTPUT PORTB
#define LED_DDR DDRB
#define LED_PIN PB6

#define DHT_OUTPUT PORTB
#define DHT_INPUT PINB
#define DHT_DDR DDRB
#define DHT_PIN PB7

/* 16.000MHz */
#define USART_BAUDRATE 0x33
#endif /* LED_OUTPUT */

#define STATUS_LED_ON LED_DDR |= (1 << LED_PIN); \
                      LED_OUTPUT |= (1 << LED_PIN)

#define STATUS_LED_BLINK LED_DDR |= (1 << LED_PIN); \
                         LED_OUTPUT |= (1 << LED_PIN); \
                         _delay_ms(500); \
                         LED_OUTPUT &= ~(1 << LED_PIN); \
                         _delay_ms(500); \
                         LED_OUTPUT |= (1 << LED_PIN); \
                         _delay_ms(500); \
                         LED_OUTPUT &= ~(1 << LED_PIN);

#define STATUS_LED_OFF LED_OUTPUT &= ~(1 << LED_PIN)

#endif /* CONFIG_H */
