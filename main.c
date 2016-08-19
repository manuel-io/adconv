#include <util/delay.h>
#include <avr/io.h>
#include <stdio.h>
#include "include/config.h"
#include "include/hd44780.h"
#include "include/dht11.h"
#include "include/adc.h"

int
main(void)
{
  uint8_t dht[DHT_DATASIZE];
  char line[LCD_LINEWIDTH];

  dht_init();
  lcd_init();

  for (;;) {
    dht_query(dht);

    if (dht_check(dht) && dht[4] != 0) {
      STATUS_LED_BLINK;
    } else {
      STATUS_LED_ON;
    }

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
  
      sprintf(line, "%d%%", (uint8_t)(adc_read(LDR_CHANNEL)*100/220));
      lcd_clear();
      lcd_string("Light:");
      lcd_setcursor(0, 2);
      lcd_string(line);

      _delay_ms(3000);

      sprintf(line, "%d%%", (uint8_t)(adc_read(FC28_CHANNEL)*100/255));
      lcd_clear();
      lcd_string("Moisture:");
      lcd_setcursor(0, 2);
      lcd_string(line);

      _delay_ms(3000);
    }
  }

  return 0;
}
