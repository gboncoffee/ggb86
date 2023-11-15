#define MSG "Hello from the kernel!"

/* Yep that's right. */
void main(void)
{
	int i;
	char msg[] = MSG;
	char *vm = (char*) 0xB8000;

	for (i = 0; i < sizeof(MSG); i++)
		vm[800 + i * 2] = msg[i];
}
