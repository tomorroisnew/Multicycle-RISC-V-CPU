# 0 "test.c"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "test.c"






void main() {


    while (1) {
        *(volatile int *)0xFFFFFFF0 = 0xDEADBEEF;

        *(volatile int *)0xFFFFFFF0 = 0x00000000;
    }
}
