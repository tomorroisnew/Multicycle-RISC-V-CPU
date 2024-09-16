#define LED_ADDR 0xFFFFFFF0  // Define a memory-mapped I/O address

void test(){
    *(volatile int *)LED_ADDR = 0xFFFFFFFF;
}

void delay() {
    test();  // Simple delay loop
    *(volatile int *)LED_ADDR;
}

void main() {
    delay();
    //volatile int *led = (volatile int *)LED_ADDR;  // Create a pointer to the LED address
    *(volatile int *)LED_ADDR = 0x0;  // Simple delay loop
    *(volatile int *)LED_ADDR;

    //while (1) {
    //    *led = 0xFFFFFFFF;  // Set all bits to 1 (turn on the LED)
    //    delay();
    //    *led = 0x00000000;  // Set all bits to 0 (turn off the LED)
    //}
}
