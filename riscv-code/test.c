#define LED_ADDR 0xFFFFFFF0  // Define a memory-mapped I/O address

void transmit_uart(char c) {
    while (*(volatile char *)0xFFFFFFF7 != 0x00){}; // Wait for the status register to be 0x00 which indicate idle
    *(volatile char *)0xFFFFFFF5 = c; //data
    *(volatile char *)0xFFFFFFF4 = 0xFF; //control
    return;
}

void test(){
    *(volatile int*)LED_ADDR = 0xFFFFFFFF;
}

void delay() {
    *(volatile int*)LED_ADDR = 0xEEEEEEEE;
    test();
    *(volatile int*)LED_ADDR = 0xDDDDDDDD;
}

int main() {
    *(volatile int*)LED_ADDR = 0xAAAAAAAA;
    test();
    *(volatile int*)LED_ADDR = 0xBBBBBBBB;
    delay();
    test();
    *(volatile int*)LED_ADDR = 0xCCCCCCCC;
    delay();
    //transmit_uart('H');
    //transmit_uart('e');
    //transmit_uart('l');
    //transmit_uart('l');
    //transmit_uart('o');
    //transmit_uart(' ');
    //transmit_uart('W');
    //transmit_uart('o');
    //transmit_uart('r');
    //transmit_uart('l');
    //transmit_uart('d');
    //transmit_uart('\n');
    //*(volatile char *)0xFFFFFFF0 = 0xAA;
    //*(volatile char *)0xFFFFFFF1 = 0xBB;
    //*(volatile char *)0xFFFFFFF2 = 0xCC;
    //*(volatile char *)0xFFFFFFF3 = 0xDD;
    //*(volatile char *)0x00000501 = 0xFF;
    //while (*(volatile char *)0x00000501 != 0x00){*(volatile char *)0x00000501 -= 1;};
    //*(volatile char *)0x00000501 = 0xFF;
    //*(volatile char *)0xFFFFFFF1;
    //*(volatile char *)0xFFFFFFF5 = 'H'; //data
    //*(volatile char *)0xFFFFFFF4 = 0xFF; //control
    //while (*(volatile char *)0xFFFFFFF7 != 0x00){} //wait
    //*(volatile char *)0xFFFFFFF5 = 'E'; //data
    //*(volatile char *)0xFFFFFFF4 = 0xFF; //control
    return 0;
}
