# 0 "test.c"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "test.c"


void transmit_uart(char c) {
    while (*(volatile char *)0xFFFFFFF7 != 0x00){};
    *(volatile char *)0xFFFFFFF5 = c;
    *(volatile char *)0xFFFFFFF4 = 0xFF;
    return;
}

void test(){
    *(volatile int*)0xFFFFFFF0 = 0xFFFFFFFF;
}

void delay() {
    *(volatile int*)0xFFFFFFF0 = 0xEEEEEEEE;
    test();
    *(volatile int*)0xFFFFFFF0 = 0xDDDDDDDD;
}

int main() {
    *(volatile int*)0xFFFFFFF0 = 0xAAAAAAAA;
    test();
    *(volatile int*)0xFFFFFFF0 = 0xBBBBBBBB;
    delay();
    test();
    *(volatile int*)0xFFFFFFF0 = 0xCCCCCCCC;
    delay();
# 54 "test.c"
    return 0;
}
