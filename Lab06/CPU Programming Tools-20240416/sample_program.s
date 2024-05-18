loadi 1 0x03 // r1 = 3
loadi 2 0x04 // r2 = 4
mult 4 1 2 // r4 = r1 * r2
sll 4 4 0x03 // r4 = r1 << 3
srl 4 4 0xFD // r4 = r1 >> 3
loadi 5 0xF0 // r5 = -3
sla 5 5 0x02 // r5 = r5 << 2
sra 5 5 0xFE // r5 = r5 >> 2
