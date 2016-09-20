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
static void uart_putstr(uint8_t *);
static uint8_t uart_start(void);
static void uart_init(void);
uint8_t uart_send(int8_t, uint8_t, uint8_t, uint8_t);

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
  if (uart_getc() == 0x2a) {
    uart_getc();
    uart_putstr((uint8_t *)"*");
    while (uart_getc() != 0x2d);
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
  
  fd = open("/tmp/ttyS21", O_RDWR);
  cfsetospeed(&tio,B9600);
  cfsetispeed(&tio,B9600);
  tcsetattr(fd, TCSANOW, &tio);
}

uint8_t
uart_send(int8_t temp, uint8_t air, uint8_t soil, uint8_t light)
{
  char data[16];

  while (!uart_start());

  sprintf(data, "- %d %d %d %d", temp, air, soil, light);
  uart_putstr((uint8_t *)data);
  
  return 1;
}

int
main()
{
  uart_init();

  while (1) {
    uart_send((rand() % 50), \
              (rand() % 100), \
              (rand() % 100), \
              (rand() % 100));
    sleep(10);
  }

  close(fd);
  return EXIT_SUCCESS;
}
