        .data
start:  .double 3.0
fact:   .double 6.0
flag:   .double -1.0
negone: .double -1.0
two:    .double 2.0
pi:     .double 3.14159265359

        .text

#reserve $f2 x, $t1 n, $f4 i, $f6 fact, $f8 flag, $f10 sub, $f12 exp

main:
        li $v0,7
        syscall
        li $v0,5
        syscall
        add $t0,$v0,$zero
        li $t1,2  #we seed the initial iteration
        l.d $f4,start
        l.d $f6,fact
        l.d $f8,flag
        l.d $f10,negone
        l.d $f18,two
        l.d $f20, pi
        c.le.d $f0, $f20
        bc1f normalize
        mov.d $f2,$f0
        mul.d $f12,$f2,$f2
        mul.d $f12,$f12,$f2
        div.d $f14,$f12,$f6
        mul.d $f14,$f14,$f8
        mul.d $f8,$f8,$f10
        add.d $f2,$f2,$f14
        add.d $f4,$f4,$f18



step:
        #Let it rip
        bgt $t1,$t0,jump
        add.d $f16,$f4,$f10
        mul.d $f6,$f6,$f16
        mul.d $f6,$f6,$f4
        mul.d $f12,$f12,$f0
        mul.d $f12,$f12,$f0
        div.d $f14,$f12,$f6
        mul.d $f14,$f14,$f8
        mul.d $f8,$f8,$f10
        add.d $f2,$f2,$f14
        add.d $f4,$f4,$f18
        addi $t1,$t1,1
        b step


normalize:
        mul.d $f22,$f20,$f18
        mul.d $f24,$f20,$f0
        add.d $f26,$f0,$f20
        div.d $f26,$f26,$f22
        floor.w.d  $f26,$f26
        cvt.d.w  $f26,$f26
        sub.d $f28,$f0,$f22
        mul.d $f0,$f26,$f28
        mov.d $f12,$f0
        mov.d $f2,$f0
        mul.d $f12,$f2,$f2
        mul.d $f12,$f12,$f2
        div.d $f14,$f12,$f6
        mul.d $f14,$f14,$f8
        mul.d $f8,$f8,$f10
        add.d $f2,$f2,$f14
        add.d $f4,$f4,$f18




jump:
        mov.d $f12,$f2
        li $v0,3
        syscall
        jr $ra
