# 0 "test.c"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "test.c"
# 18 "test.c"
void main() {

    while (1) {
        *(volatile int *)0xFFFFFFF0 = 0x00000000;
        for (int i = 0; i < 5000; i++) {}
        *(volatile int *)0xFFFFFFF0 = 0xFFFFFFFF;
        for (int i = 0; i < 5000; i++) {}
    }
    return;
}
