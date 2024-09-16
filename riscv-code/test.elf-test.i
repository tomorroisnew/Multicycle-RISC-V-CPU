# 0 "test.c"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "test.c"


void test(){
    *(volatile int *)0xFFFFFFF0 = 0xFFFFFFFF;
}

void delay() {
    test();
    *(volatile int *)0xFFFFFFF0;
}

void main() {
    delay();

    *(volatile int *)0xFFFFFFF0 = 0x0;
    *(volatile int *)0xFFFFFFF0;






}
