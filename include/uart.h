#ifndef UART_H

#define IS_SET(r, b) (r & (1 << b)) >> b == 1
#define IS_UNSET(r, b) (r & (1 << b)) >> b == 0

void uart_init(void);
uint8_t uart_send(uint8_t, uint8_t, uint8_t, uint8_t);

#endif /* UART_H */
