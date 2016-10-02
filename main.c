#include <avr/interrupt.h>
#include <avr/sleep.h>
#include <util/delay.h>
#include <avr/io.h>
#include <stdio.h>
#include "include/config.h"
#include "include/hd44780.h"
#include "include/dht11.h"
#include "include/adc.h"
#include "include/uart.h"

int
main(void)
{
  uint8_t ldr;
  uint8_t fc28;
  uint8_t dht[DHT_DATASIZE];
  char line[LCD_LINEWIDTH];

  dht_init();
  lcd_init();
  uart_init();

  for (;;) {
    dht_query(dht);
    ldr = (uint8_t)(adc_read(LDR_CHANNEL)*100/220);
    fc28 = (uint8_t)(adc_read(FC28_CHANNEL)*100/255);

    if (dht_check(dht) && dht[4] != 0) {
      STATUS_LED_BLINK;
    } else {
      STATUS_LED_ON;
    }

    #ifndef DISABLE_XCONN
    uart_send(dht[2], dht[0], fc28, ldr);
    #endif /* DISABLE_XCONN */

    for (uint8_t i = 0; i < 10; i++) {

      sprintf(line, "%d\337 C, %d\337 F", dht[2], (uint8_t)((dht[2]*9*0.2) + 32));
      lcd_clear();
      lcd_string("Temperature:");
      lcd_setcursor(0, 2);
      lcd_string(line);

      _delay_ms(3000);

      sprintf(line, "%d%%", dht[0]);
      lcd_clear();
      lcd_string("Humidity:");
      lcd_setcursor(0, 2);
      lcd_string(line);

      _delay_ms(3000);
  
      sprintf(line, "%d%%", ldr);
      lcd_clear();
      lcd_string("Light:");
      lcd_setcursor(0, 2);
      lcd_string(line);

      _delay_ms(3000);

      sprintf(line, "%d%%", fc28);
      lcd_clear();
      lcd_string("Moisture:");
      lcd_setcursor(0, 2);
      lcd_string(line);

      _delay_ms(3000);
    }

    #ifndef POWERSAVING_OFF
    uint8_t i = 0;

    /* CPU-Takt / 1024 */
    TCCR1B |= (1 << CS12) | (1 << CS10);
    TIMSK |= (1 << TOIE1);

    sei();

    lcd_off();
    adc_disable();
    set_sleep_mode(SLEEP_MODE_IDLE);

    #ifndef V2
    while (i < 100) {
    #else
    while (i < 200) {
    #endif /* V2 */
      sleep_mode();
      i++;
    }

    cli();
    lcd_on();
    #endif /* POWERSAVING_OFF */
  }

  return 0;
}

ISR(TIMER1_OVF_vect)
{

}
