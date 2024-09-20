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

int main() {
    transmit_uart('H');
    transmit_uart('e');
    transmit_uart('l');
    transmit_uart('l');
    transmit_uart('o');
    transmit_uart(' ');
    transmit_uart('W');
    transmit_uart('o');
    transmit_uart('r');
    transmit_uart('l');
    transmit_uart('d');
    transmit_uart('\n');
# 36 "test.c"
    return 0;
}
