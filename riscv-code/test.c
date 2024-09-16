#define LED_ADDR 0xFFFFFFF0  // Define a memory-mapped I/O address

//void delay() {
//    for (volatile int i = 0; i < 2; i++);  // Simple delay loop
//}


//void delay() {
//    *(volatile int *)LED_ADDR = 0xFFFFFFFF;  // Simple delay loop
//}
//
//void gitna() {
//    *(volatile int *)LED_ADDR = 0xEEEEEEEE;  // Simple delay loop
//    delay();
//    *(volatile int *)LED_ADDR = 0xDEDEDEDE;  // Simple delay loop
//}

void main() {
    //volatile int *led = (volatile int *)LED_ADDR;  // Create a pointer to the LED address
    while (1) {
        *(volatile int *)LED_ADDR = 0x00000000;  // Turn on the LED
        for (int i = 0; i < 5000; i++) {}  // Wait a bit
        *(volatile int *)LED_ADDR = 0xFFFFFFFF;  // Turn off the LED
        for (int i = 0; i < 5000; i++) {}  // Wait a bit
    }
    return;
}
