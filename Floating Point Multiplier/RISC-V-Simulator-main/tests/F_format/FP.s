li a4, 0x12345678
li a5, 0x12345678
li a6, 100
sw a4, 100(a6)
sw a5, 200(a6)
flw f12, 100(a6)
flw f13, 200(a6)
fadd.s f14, f12, f13
fsub.s f15, f12, f13
fmul.s f16, f12, f13
fdiv.s f17, f12, f13
fsqrt.s f21, f12
feq.s a6, f12, f13
flt.s a7, f12, f13
fle.s t1, f12, f13
fcvt.w.s t2, f12
fcvt.wu.s t3, f12
fcvt.s.w f19, a4
fcvt.s.wu f20, a4
jr ra
