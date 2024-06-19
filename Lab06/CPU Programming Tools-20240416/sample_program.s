loadi 0 0x09 // r0 = 9
loadi 1 0x01 // r1 = 1
swd 0 1 // m1 = r0 = 9
swi 1 0x00 // m0 = r1 = 1
lwd 2 1 // r2 = m1 = 9
lwd 3 1 // r3 = m1 = 9
sub 4 0 1 // r4 = r0 - r1 = 8
swi 4 0x02 // m2 = r4 = 8
lwi 5 0x02 // r5 = m2 = 8
swi 4 0x20 // m20 = r4 = 8
lwi 6 0x20 // r6 = m20 = 8
