#include <avr/io.h>
#include "include/config.h"
#include "include/uart.h"

/* The UMSEL bit in USART Control and Status Register C (UCSRC)
 * selects between asynchronous and synchronous operation. Double
 * speed (Asynchronous mode only) is cont rolled by the U2X found in
 * the UCSRA Register. When using Synchronous mode (UMSEL = 1), the
 * Data Direction Register for the XCK pin (DDR_XCK) controls whether
 * the clock source is internal (Master mode) or external (Slave
 * mode). The XCK pin is only active when using Synchronous mode.
 */

/* UCSRA: USART Control and Status Register A
 * ------------------------------------------------------------
 * | 7     | 6     | 5     | 4    | 3    | 2    | 1    | 0    |
 * | RXC   | TXC   | UDRE  | FR   | DOR  | PE   | U2X  | MPCM |
 * ------------------------------------------------------------
 *
 * UCSRB: USART Control and Status Register B
 * -------------------------------------------------------------
 * | 7     | 6     | 5     | 4    | 3    | 2     | 1    | 0    |
 * | RXCIE | TXCIE | UDRIE | RXEN | TXEN | UCSZ2 | RXB8 | TXB8 |
 * -------------------------------------------------------------
 *
 * UCSRC: USART Control and Status Register C
 * --------------------------------------------------------------
 * | 7     | 6     | 5    | 4    | 3    | 2     | 1     | 0     |
 * | URSEL | UMSEL | UPM1 | UPM0 | USBS | UCSZ1 | UCSZ2 | UCPOL |
 * --------------------------------------------------------------
 *
 */

static uint8_t uart_getc(void);
static void uart_putc(uint8_t);
static void uart_putstr(uint8_t *);
static uint8_t uart_start(void);

static void
uart_putc(uint8_t b)
{
  /* The UDRE Flag indicates if the transmit buffer (UDR) is ready to
   * receive new data. If UDRE is one, the buffer is empty, and
   * therefore ready to be written.
   */
  while (IS_UNSET(UCSRA, UDRE));
  UDR = b;
}

static uint8_t
uart_getc() {
  /* This flag bit is set when there are unread data in the receive
   * buffer and cleared when the receive buffer is empty (that is,
   * does not contain any unread data).
   */
  while (IS_UNSET(UCSRA, RXC));
  return UDR;
}

static void
uart_putstr(uint8_t *data)
{
  while (*data) {
    uart_putc(*data);
    data++;
  }
  uart_putc('\n');
}

static uint8_t
uart_start()
{
  uint8_t c = 0;
  if ((c = uart_getc()) == 0x2a) {
    uart_getc();
    uart_putstr((uint8_t *)"*");
    while ((c = uart_getc()) != 0x2d);
    return 1;
  }

  return 0;
}

uint8_t
uart_send(uint8_t temp, uint8_t air, uint8_t soil, uint8_t light)
{
  while (!uart_start());

  uart_putc(0x2d);
  uart_putc(' ');
  /* Temperature */
  uart_putc(temp);
  uart_putc(' ');
  /* Air humidity */
  uart_putc(air);
  uart_putc(' ');
  /* Soil moisture */
  uart_putc(soil);
  uart_putc(' ');
  /* Light level */
  uart_putc(light);
  uart_putc('\n');
  
  return 1;
}

void
uart_init() {
  /* Enable receiver and transmitter */
  UCSRB |= (1 << RXEN) | (1 << TXEN);
  
  /* URSEL 1: If URSEL is one,
   * the UCSRC setting will be updated.
   */
  UCSRC |= (1 << URSEL);

  /* Asynchronous, No parity, 1 Stop bit, 8 Data bits */
  UCSRC &= ~(1 << UMSEL) & ~(1 << UPM1) & ~(1 << UPM0) & ~(1 << USBS);
  UCSRC |= (1 << UCSZ1) | (1 << UCSZ1);

  /* Baudrate: 9600bps */
  UBRRL = USART_BAUDRATE;
}
