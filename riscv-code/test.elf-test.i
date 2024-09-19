# 0 "test.c"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "test.c"
# 22 "test.c"
void main() {
# 37 "test.c"
        *(volatile int *)0xFFFFFFF0 = 0x00000000;
        *(volatile short *)0xFFFFFFF0 = 0xFFFF;
        *(volatile char *)0xFFFFFFF0 = 0xDE;






    return;
}
