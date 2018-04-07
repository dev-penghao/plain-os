extern void hlt(void);

int a();
short b(short s);

void main(void) {
	a();
	for(;;) {
		hlt();
	}

}

int a()
{
	b(62);
	return 0;
}

short b(short s)
{
	return s;
}
