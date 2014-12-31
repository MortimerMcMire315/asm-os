//kernel.c

void kmain(void) {
    char *str = "Seth's excellent kernel.";
    char *vidptr = (char*)0xb8000; //Beginning of video memory
    unsigned int i = 0;
    unsigned int j = 0;

    while(j < 80*25*2) {
        vidptr[j] = ' ';
        vidptr[j+1] = 0x07; //Light gray
        j = j + 2;
    }

    j = 0;
    while(str[j] != '\0') {
        vidptr[i] = str[j];
        vidptr[i+1] = 0x07;
        j++;
        i = i + 2;
    }

    return;
}
