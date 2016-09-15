#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>

/* socat pty,raw,echo=0,link=/home/workspace/ttyS20 \
 *   pty,raw,echo=0,link=/home/workspace/ttyS21
 */

static uint8_t uart_getc(void);
static void uart_putc(uint8_t);
uint8_t uart_send(uint8_t, uint8_t, uint8_t, uint8_t);

static int fd;
static struct termios tio;

static uint8_t
uart_getc()
{
  uint8_t data;
  ssize_t bytes = read(fd, &data, 1);
  if (bytes == 1) {}
  return data;
}

static void
uart_putc(uint8_t data)
{
  ssize_t bytes = write(fd, &data, 1);
  if (bytes == 1) {}
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
    printf("%c\n", c);
    c = uart_getc();
    uart_putstr((uint8_t *)"*");
    while ((c = uart_getc()) != 0x2d);
    printf("%c\n", c);
    return 1;
  }

  return 0;
}

static void
uart_init()
{
  memset(&tio, 0, sizeof(tio));
  tio.c_iflag = 0;
  tio.c_oflag = 0;
  tio.c_cflag = CS8 | CREAD | CLOCAL;
  tio.c_lflag = 0;
  tio.c_cc[VMIN] = 1;
  tio.c_cc[VTIME] = 5;
  
  fd = open("/home/workspace/ttyS21", O_RDWR);
  cfsetospeed(&tio,B9600);
  cfsetispeed(&tio,B9600);
  tcsetattr(fd, TCSANOW, &tio);
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

int
main()
{
  uart_init();
  while (1) {
    uart_send(0x4f, 0x50, 0x51, 0x52);
    sleep(10);
  }
  close(fd);
  return EXIT_SUCCESS;
}
