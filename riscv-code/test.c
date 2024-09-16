#define LED_ADDR 0xFFFFFFF0  // Define a memory-mapped I/O address

//void delay() {
//    for (volatile int i = 0; i < 2; i++);  // Simple delay loop
//}

void main() {
    //volatile int *led = (volatile int *)LED_ADDR;  // Create a pointer to the LED address

    while (1) {
        *(volatile int *)LED_ADDR = 0xDEADBEEF;  // Set all bits to 1 (turn on the LED)
        //delay();
        *(volatile int *)LED_ADDR = 0x00000000;  // Set all bits to 0 (turn off the LED)
    }
}
