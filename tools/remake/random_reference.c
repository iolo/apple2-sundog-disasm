/* sim65 driver for the source-extracted native RNG loop; no Apple II I/O. */
#include <stdio.h>
extern unsigned char random_state[4];
extern unsigned int random_next(void);
int main(void) {
    static unsigned long seeds[] = {0,1,0x40UL,0x80000000UL,0xffffffffUL,0x12345678UL,0x53444f47UL};
    unsigned int i,j,k,value;
    unsigned long state;
    puts("[");
    for(i=0;i<7;i++) {
        state=seeds[i];
        for(k=0;k<4;k++) { random_state[k]=(unsigned char)state;state>>=8; }
        printf("{\"seed\":%lu,\"draws\":[",seeds[i]);
        for(j=0;j<16;j++) {
            value=random_next();
            state=0;
            for(k=0;k<4;k++)state|=((unsigned long)random_state[k])<<(8*k);
            printf("%s{\"value\":%u,\"state\":%lu}",j?",":"",value,state);
        }
        printf("]}%s\n",i==6?"":",");
    }
    puts("]");
    return 0;
}
