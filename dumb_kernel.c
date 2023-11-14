/* Yep that's right. */
void main(void)
{
	char *vm = (char*) 0xB8000;
	*vm = 'X';
}
