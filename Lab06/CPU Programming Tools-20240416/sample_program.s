loadi 4 0x0A // r4 = 10
loadi 5 0x01 // r5 = 1
loadi 6 0x01 // r6 = 1
loadi 7 0x09 // r7 = 9
sub 4 4 5 // r4 = r4 - r5
beq 0x01 4 6 // branch one line forward if r4 == r6
j 0xFD // jump two lines up
add 1 4 7 // r1 = r4 + r7