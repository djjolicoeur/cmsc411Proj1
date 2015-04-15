        #Taylor exapnasion approximation of tangent
        #Daniel Jolicoeur | CMSC411 | April, 2015
        #sin(x)/cos(x) (see sine.s and cosine.s for implentation details)
        #important registers:
        #$f2 X, $t1 n (loop counter), $f4 i (double iteration counter),
        #$f6 factorial, $f8 flag, $f10 sub, $f12 exp
        .data
        #sine_start: The taylor expansion to approxomate sine is odd,
        #thus we begin at n = 3 (at 1 everything cancels, leaving X).
        #this allows us to efficiently calcuate the next exponent
        #by keeping a running track of x^(start + 2) and
        #calculate the exponenteation by only multiplying the
        #running value by X twice more. each iteration only need
        #calculate X^current * X * X

sine_start:  .double 3.0

        #cosine_start: The taylor expansion to approxomate cosine is even
        #thus begins at n = 2 (at zero everything cancels, leaving 1).
        #this allows us to efficiently calcuate the next exponent
        #by keeping a running track of x^(start + 2) and
        #calculate the exponenteation by only multiplying the
        #running value by X twice more. each iteration only need
        #calculate X^current * X * X

cosine_start:    .double 2.0

        #sine_fact: it is uneccessary to re-calculate the entire factorial every iteration.
        #we know our first factorial is 3! which is 6. From there, each iteration
        #is simply calculated by a subtraction and two multiplications, whereby
        #we simply take the fact_current * (i_current - 1.0) * (i_current)

sine_fact:   .double 6.0

cosine_fact:    .double 2.0

        #flag: used to alternate between addition and subtraction
        #of terms in the summation

flag:   .double -1.0

        #negone: variable for negative 1, which is usfull in many situations in
        #the code (flipping the flag for example)

negone: .double -1.0

        #two:  needed to calculate 2pi

two:    .double 2.0

        #pi: because trigonometry! double representation of pi

one:    .double 1.0

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

        l.d $f4,sine_start                   #load up initial and static values
        l.d $f6,sine_fact
        l.d $f8,flag
        l.d $f10,negone
        l.d $f18,two
        l.d $f20, pi

        mul.d $f22,$f20,$f18            #normalize the double passed (theta) between
        mul.d $f24,$f20,$f0             #-pi and pi. theta - 2pi*floor(theta + pi)/2pi
        add.d $f26,$f0,$f20
        div.d $f26,$f26,$f22
        floor.w.d  $f26,$f26
        cvt.d.w  $f26,$f26
        mul.d $f28,$f26,$f22
        sub.d $f0,$f0,$f28

                                        #We set our initial values to the
        mov.d $f2,$f0                   #the point in the summation s.t. i =
                                        #this it is necessary to "seed" the loop
        mul.d $f12,$f2,$f2              #before we iterate.  The code to the left is
        mul.d $f12,$f12,$f2             #the equivalent of sum(X - (X^3/3!)).
        div.d $f14,$f12,$f6             #from here, we can step through the
        mul.d $f14,$f14,$f8             #remainder of the series.
        mul.d $f8,$f8,$f10
        add.d $f2,$f2,$f14              #$f2 gets (X + (-1 * (x^3/3!)))
        add.d $f4,$f4,$f18



sine_step:
        #Let it rip                     #This code is the iterative step.
        bgt $t1,$t0,cosine              #Each iteration updates the current
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
        b sine_step

cosine:

        mov.d $f20,$f2                  #hold our sine result in $f20
        add $t0,$v0,$zero
        li $t1,2
        l.d $f4,cosine_start            #load up initial cosine values
        l.d $f6,cosine_fact
        l.d $f8,flag
        l.d $f30,one

        mov.d $f2,$f0                   #the point in the summation s.t. i = 2,
                                        #this it is necessary to "seed" the loop
        mul.d $f12,$f2,$f2              #before we iterate.  The code to the left is
                                        #the equivalent of sum(1 - (X^2/2!)).
        div.d $f14,$f12,$f6             #from here, we can step through the
        mul.d $f14,$f14,$f8             #remainder of the series.
        mul.d $f8,$f8,$f10
        add.d $f2,$f30,$f14             #$f2 gets (1 + 	(-1 * (x^2/2!)))
        add.d $f4,$f4,$f18



cosine_step:
        #Let it rip                     #This code is the iterative cosine step.
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
        b cosine_step




jump:

        div.d $f2,$f20,$f2              #$f2 gets sin(x)/cos(x)
        mov.d $f12,$f2                  #print results to screen
        li $v0,3                        #and return
        syscall
        jr $ra
