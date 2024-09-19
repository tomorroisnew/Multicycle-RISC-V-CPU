# 0 "test.c"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "test.c"
# 10 "test.c"
void delay() {
    *(volatile int *)0xFFFFFFF0 = 0xFFFFFFFF;
}

void gitna() {
    *(volatile int *)0xFFFFFFF0 = *(volatile int *)0xFFFFFFF0 + 1;

    *(volatile int *)0xFFFFFFF0 = 0xEEEEEEEE;
    delay();
    *(volatile int *)0xFFFFFFF0 = 0xDEDEDEDE;
}

void main() {
# 36 "test.c"
    while(1) {




        *(volatile int *)0xFFFFFFF0 = 0xDDDDDDDD;
        gitna();
        *(volatile int *)0xFFFFFFF0 = 0xAAAAAAAA;
        delay();
        *(volatile int *)0xFFFFFFF0 = 0x55555555;
        gitna();
    }
    return;
}
