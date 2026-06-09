#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <irq.h>
#include <uart.h>
#include <console.h>
#include <generated/csr.h>
static int read_int(void)
{
    char buf[16];
    int i = 0;
    char c;
    while(1) {
        c = uart_read();
        if(c == '\r' || c == '\n') {
            buf[i] = '\0';
            printf("\n");
            break;
        }
        if(c == 8 || c == 127) {   /* backspace */
            if(i > 0) {
                i--;
                printf("\b \b");
            }
            continue;
        }
        if(i < 15) {
            buf[i++] = c;
            printf("%c", c);        /* eco */
        }
    }
    return atoi(buf);
}

int main(void)
{
	int a,b,c;
	printf("Testing verilog multiplier \n");
	while(1) {
        printf("Ingrese A: ");
        a = read_int();
        printf("Ingrese B: ");
        b = read_int();

		mult0__A_write(a);
		mult0__B_write(b);
		mult0_init_write(1);
		mult0_init_write(0);
        while(mult0_done_read() == 0);
		c = mult0_pp_read();
        printf("A = %d, B = %d, A*B = %d\n\n", a, b, c);
	}
	return 0;
}


