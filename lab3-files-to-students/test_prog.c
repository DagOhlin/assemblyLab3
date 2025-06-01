/* test_simple.c */
#include <stdio.h>
#include "my_iolib.h"

int main(void) {
    long long värde;

    printf("Skriv en rad och tryck Enter:\n");
    inImage();              /* Ladda in en rad till input-bufferten */

    printf("Nu anropas getInt()\n");
    värde = getInt();       /* Läser heltal från buffern (kallar inImage vid behov) */

    printf("getInt() returnerade: %lld\n", värde);
    return 0;
}
