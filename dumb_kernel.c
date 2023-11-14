/* Yep that's right. */
void _start(void)
{
	char *vm = (char*) 0xB8000;
	*vm = 'X';
}
