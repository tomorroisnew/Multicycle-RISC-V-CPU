#define LED_ADDR 0xFFFFFFF0  // Define a memory-mapped I/O address

//void delay() {
//    for (volatile int i = 0; i < 2; i++);  // Simple delay loop
//}

//void delay() {
//    for (volatile int i = 0; i < 10000; i++);  // Simple delay loop
//}
//void delay() {
//    *(volatile int *)LED_ADDR = 0xFFFFFFFF;  // Simple delay loop
//}
////
//void gitna() {
//    *(volatile int *)LED_ADDR = *(volatile int *)LED_ADDR + 1;
//    gitna();
//    //*(volatile int *)LED_ADDR = 0xEEEEEEEE;  // Simple delay loop
//    //delay();
//    //*(volatile int *)LED_ADDR = 0xDEDEDEDE;  // Simple delay loop
//}

void main() {
    //volatile int *led = (volatile int *)LED_ADDR;  // Create a pointer to the LED address
    //for (int i = 0; i < 2; i++) {
    //    *(volatile int *)LED_ADDR = 0x00000000;  // Turn on the LED
    //    *(volatile int *)LED_ADDR = 0xFFFFFFFF;  // Turn off the LED
    //}
    //*(volatile uint32_t *)(LED_ADDR & ~0x3) = (*(volatile uint32_t *)(LED_ADDR & ~0x3) & ~(0xFF << (BYTE_OFFSET * 8))) | (0xFF << (BYTE_OFFSET * 8));
    //*(volatile int *)LED_ADDR = 0xFFFFFFFF;
    //if(*(volatile int *)LED_ADDR == 0xFFFFFFFF) {
    //    *led = 0xEEEEEEEE;
    //}
    //else {
    //    *(volatile int *)LED_ADDR = 0xDEDEDEDE;
    //}
    //while(1) {
        *(volatile int *)LED_ADDR = 0x00000000;
        *(volatile short *)LED_ADDR  = 0xFFFF;
        *(volatile char *)LED_ADDR = 0xDE;
        *(volatile char *)LED_ADDR;
        //gitna();
        //*(volatile int *)LED_ADDR = 0xAAAAAAAA;
        //delay();
        //*(volatile int *)LED_ADDR = 0x55555555;
        //gitna();
    //}
    return;
}
