#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include "include/config.h"
#include "include/dht11.h"

/* DHT11 Temperature & Humidity Sensor features a temperature &
 * humidity sensor complex with a calibrated digital signal output.
 */

static void dht_reset(void);
static void dht_start(void);
static void dht_response(void);
static uint8_t dht_bit(void);
static uint8_t dht_byte(void);

static void
dht_start()
{
  /* The I/O is set to output and pulls the line down for at least
   * 18ms at the same time. Then the microprocessor I/O is set to
   * input state. Due to the pull up resistor the DATA line will be
   * high.
   */

  /* OUTOUT */
  DHT_DDR |= (1 << DHT_PIN);

  /* 20us DOWN */
  DHT_OUTPUT &= ~(1 << DHT_PIN);
  _delay_ms(18);

  /* 40us UP */
  DHT_OUTPUT |= (1 << DHT_PIN);
  _delay_us(1);

  /* INPUT */
  DHT_DDR &= ~(1 << DHT_PIN);
}

static void
dht_response()
{
  /* DATALINE IS ON HIGH DUE TO PULL UP */

  /* WHILE HIGH */
  while (IS_SET(DHT_INPUT, DHT_PIN)) {
    _delay_us(1);
  }

  /* 80us LOW */
  while (IS_UNSET(DHT_INPUT, DHT_PIN)) {
    _delay_us(1);
  }
}

static uint8_t
dht_bit()
{
  uint8_t i = 0;

  /* We do not know what the status of the data line is. The default is,
   * to think it is high due to the pull up resistor. But we can fall
   * through if it's not.
   */

  /* WHILE HIGH */
  while (IS_SET(DHT_INPUT, DHT_PIN)) {
    _delay_us(1);
  }

  /* 50us LOW */
  while (IS_UNSET(DHT_INPUT, DHT_PIN)) {
    _delay_us(1);
  }

  /* 0 BIT 30us, 1 BIT 70us */
  while (IS_SET(DHT_INPUT, DHT_PIN)) {
    _delay_us(1);
    i++;
  }

  /* LOW EOT */

  if(i < 35) return 0;
  else return 1;
}

static uint8_t
dht_byte()
{
  uint8_t byte = 0;

  for(uint8_t i = 0; i < 8; i++) {
    byte |= (dht_bit() << (7-i));
  }

  return byte;
}

static void
dht_reset()
{
  DHT_DDR |= (1 << DHT_PIN);
  DHT_OUTPUT |= (1 << 7);
  _delay_ms(100);
}

void
dht_query(uint8_t *data)
{
  cli();
  dht_reset();
  dht_start();
  dht_response();

  for(uint8_t i = 0; i < 5; i++) {
    data[i] = dht_byte();
  }

  sei();
}

uint8_t
dht_check(uint8_t *data)
{
  if (data[4] == ((data[0] + data[1] + data[2] + data[3]) & 0xff)) {
    return 1;
  } else {
    return 0;
  }
}

void
dht_init()
{
  dht_reset();
}
