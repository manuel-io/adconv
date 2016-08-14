#include <util/delay.h>
#include <avr/io.h>
#include <stdio.h>
#include "include/config.h"
#include "include/hd44780.h"
#include "include/dht11.h"
#include "include/ldr.h"

int
main(void)
{
  uint8_t dat[5];
  char line[16];

  dht_init();
  lcd_init();

  for (;;) {
    dht_query(dat);

    if (dht_check(dat) && dat[4] != 0) {
      STATUS_LED_BLINK;
      STATUS_LED_OFF;
    } else {
      STATUS_LED_ON;
    }

    for (uint8_t i = 0; i < 10; i++) {

      sprintf(line, "%d\337 C, %d\337 F", dat[2], (int)((dat[2]*9*0.2) + 32));
      lcd_clear();
      lcd_string("Temperature:");
      lcd_setcursor(0, 2);
      lcd_string(line);

      _delay_ms(3000);

      sprintf(line, "%d%%", dat[0]);
      lcd_clear();
      lcd_string("Humidity:");
      lcd_setcursor(0, 2);
      lcd_string(line);

      _delay_ms(3000);
    }
  }

  return 0;
}
