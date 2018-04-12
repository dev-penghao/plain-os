extern void hlt(void);
extern void put_string(char *c);
extern void clean_screen();

void main(void) {


	char *c="  This is frist\nThis is secend\nThis is 3th.";
	clean_screen();
	put_string(c+0x10800);
}
