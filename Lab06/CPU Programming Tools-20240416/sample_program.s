loadi 1 0xFD // r1 = 3
loadi 2 0xFC // r2 = 4
mult 4 1 2 // r4 = r1 * r2
sll 4 4 0x03 // r4 = r1 << 3
srl 4 4 0x03 // r4 = r1 >> 3
loadi 5 0xF0 // r5 = -16
sla 5 5 0x02 // r5 = r5 << 2
sra 5 5 0x02 // r5 = r5 >> 2
loadi 6 0xFD // r5 = -3
ror 6 6 0x02 // r5 = r5 >> 2 rotate
rol 6 6 0x02 // r5 = r5 << 2 rotate
loadi 7 0xF1 //
bne 0xF9 5 7 // branch to line 4
