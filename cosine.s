        #Taylor exapnasion approximation of cosine
        #Daniel Jolicoeur | CMSC411 | April, 2015
        #summation_0^n(1 - (X^2/2!) + (X^4/4!) - (X^6/6!)...)
        #important registers:
        #$f2 X, $t1 n (loop counter), $f4 i (double iteration counter),
        #$f6 factorial, $f8 flag, $f10 sub, $f12 exp
        .data
        #start: The taylor expansion to approxomate cosine is even,
        #thus begins at n = 2 (at zero everything cancels, leaving 1).
        #this allows us to efficiently calcuate the next exponent
        #by keeping a running track of x^(start + 2) and
        #calculate the exponenteation by only multiplying the
        #running value by X twice more. each iteration only need
        #calculate X^current * X * X

start:  .double 2.0

        #fact: it is uneccessary to re-calculate the entire factorial every iteration.
        #we know our first factorial is 2! which is 6. From there, each iteration
        #is simply calculated by a subtraction and two multiplications, whereby
        #we simply take the fact_current * (i_current - 1.0) * (i_current)

fact:   .double 2.0

        #flag: used to alternate between addition and subtraction
        #of terms in the summation

flag:   .double -1.0

        #negone: variable for negative 1, which is usfull in many situations in
        #the code (flipping the flag for example)

negone: .double -1.0

        #two:  needed to calculate 2pi

one:    .double 1.0

two:    .double 2.0

        #pi: because trigonometry! double representation of pi

pi:     .double 3.14159265359

        .text



main:
        li $v0,7                        #read in double value w/ syscall
        syscall
        li $v0,5                        #read in number of iterations to expand to
        syscall
        add $t0,$v0,$zero               #add zero to easily move integer into $t0
        li $t1,2                        #we seed the initial iteration, so our loop
                                        #counter can start @ 2

        l.d $f4,start                   #load up initial and static values
        l.d $f6,fact
        l.d $f8,flag
        l.d $f10,negone
        l.d $f18,two
        l.d $f20, pi
        l.d $f30, one

        mul.d $f22,$f20,$f18            #normalize the double passed (theta) between
        mul.d $f24,$f20,$f0             #-pi and pi. theta - 2pi*floor(theta + pi)/2pi
        add.d $f26,$f0,$f20
        div.d $f26,$f26,$f22
        floor.w.d  $f26,$f26
        cvt.d.w  $f26,$f26
        mul.d $f28,$f26,$f22
        sub.d $f0,$f0,$f28

                                        #We set our initial values to the
        mov.d $f2,$f0                   #the point in the summation s.t. i = 2,
                                        #this it is necessary to "seed" the loop
        mul.d $f12,$f2,$f2              #before we iterate.  The code to the left is
                                        #the equivalent of sum(1 - (X^2/2!)).
        div.d $f14,$f12,$f6             #from here, we can step through the
        mul.d $f14,$f14,$f8             #remainder of the series.
        mul.d $f8,$f8,$f10
        add.d $f2,$f30,$f14             #$f2 gets (1 + 	(-1 * (x^2/2!)))
        add.d $f4,$f4,$f18



step:
        #Let it rip                     #This code is the iterative step.
        bgt $t1,$t0,jump                #Each iteration updates the current
        add.d $f16,$f4,$f10             #exponential term as well as the
        mul.d $f6,$f6,$f16              #current factorial term.  It then
        mul.d $f6,$f6,$f4               #multiplies by the resulting term
        mul.d $f12,$f12,$f0             #(current exponent/current factorial)
        mul.d $f12,$f12,$f0             #by the "flag" to alternate the term
        div.d $f14,$f12,$f6             #and adds it to the running summation in
        mul.d $f14,$f14,$f8             #$f2.  It swaps the "flag"'s sign,
        mul.d $f8,$f8,$f10              #increments our loop counter, and our
        add.d $f2,$f2,$f14              #double iteration counter, and continues
        add.d $f4,$f4,$f18              #the process until the loop counter
        addi $t1,$t1,1                  #is greater than the target iterations
        b step



jump:
        mov.d $f12,$f2                  #print results to screen
        li $v0,3                        #and return
        syscall
        jr $ra
