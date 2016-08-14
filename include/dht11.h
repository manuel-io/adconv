#ifndef DHT11_h

#define IS_SET(r, b) (r & (1 << b)) >> b == 1
#define IS_UNSET(r, b) (r & (1 << b)) >> b == 0

void dht_query(uint8_t *);
uint8_t dht_check(uint8_t *);
void dht_init(void);

#endif /* DHT11_H */
