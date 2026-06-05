#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <irq.h>
#include <uart.h>
#include <console.h>
#include <generated/csr.h>
void my_busy_wait(unsigned int ms)
{
	timer0_en_write(0);
	timer0_reload_write(0);
	timer0_load_write(CONFIG_CLOCK_FREQUENCY/1000*ms);
	timer0_en_write(1);
	timer0_update_value_write(1);
	while(timer0_value_read()) timer0_update_value_write(1);
}
int main(void)
{
	char i;
//	irq_setmask(0);
//	irq_setie(1);
	uart_init();
	printf("Running PWM demo. \n");
	pwm_enable_write(1);
	pwm_period_write(1024*40);
	while(1) {
		for(i=1; i<40; i++){
			pwm_width_write(1024*i);
			my_busy_wait(10);
		}
		for(i=40; i>0; i--){
			pwm_width_write(1024*i);
			my_busy_wait(10);
		}
		my_busy_wait(100);
	}
	return 0;
}
