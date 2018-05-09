; Addresses for I/O
.NAME	HEX= 0xFFFFF000
.NAME	LEDR=0xFFFFF020
.NAME	KEY= 0xFFFFF080
.NAME	SW=  0xFFFFF090
.NAME	TCNT=0xFFFFF100
; Blinking speed delta (250ms)
.NAME	DLTA=0x000000FA

; a0 = blinking speed
; a1 = 0xn000
; a2 = current timer count
; a3 = current KEY state
; s2 = previous KEY state
; s0 = 0x1 (KEY[0] on)
; s1 = 0x2 (KEY[1] on)
; fp = 0x7000 (n_max, 0x8000 sets the sign bit and messes everything up)
; sp = 0x1000 (n_min)
; t0 = 0x000003E0 (top LEDs)
; t1 = 0x0000001F (bot LEDs)
	.ORIG 0x100
	xor		zero,zero,zero		; Zero the zero register, HEX, and LEDR
	add		a3,zero,zero		; Zero current and previous KEY states
	add		s2,zero,zero
	addi	zero,s0,0x1 		; Set s0 = 0x1 (KEY[0] on)
	addi	zero,s1,0x2 		; Set s1 = 0x2 (KEY[1] on)
	addi	zero,a0,DLTA		; Set blinking to default speed (500ms)
	addi	a0,a0,DLTA
	addi	zero,fp,0x7000		; Set fp = 0x7000 (n_max)
	addi	zero,sp,0x1000		; Set sp = 0x1000 (n_min)
	addi	zero,a1,0x2000		; Set n = 2 and display on HEX[3]
	sw		a1,HEX(zero)
	addi	zero,t0,0x3E0		; Set t0 = top LEDs
	addi	zero,t1,0x01F		; Set t1 = bot LEDs

LEDRLoop:
; State 1
	sw		t0,LEDR(zero)		; Top LEDs on
	call	Timer(zero)			; Wait n/4 sec
	sw		zero,LEDR(zero)		; LEDs off
	call	Timer(zero)			; Wait n/4 sec
	sw		t0,LEDR(zero)		; Repeat two more times...
	call	Timer(zero)
	sw		zero,LEDR(zero)
	call	Timer(zero)
	sw		t0,LEDR(zero)
	call	Timer(zero)
	sw		zero,LEDR(zero)
	call	Timer(zero)
; State 2
	sw		t1,LEDR(zero)		; Bot LEDs on
	call	Timer(zero)			; Wait n/4 sec
	sw		zero,LEDR(zero)		; LEDs off
	call	Timer(zero)			; Wait n/4 sec
	sw		t1,LEDR(zero)		; Repeat two more times...
	call	Timer(zero)
	sw		zero,LEDR(zero)
	call	Timer(zero)
	sw		t1,LEDR(zero)
	call	Timer(zero)
	sw		zero,LEDR(zero)
	call	Timer(zero)
; State 3
	sw		t0,LEDR(zero)		; Top LEDs on
	call	Timer(zero)			; Wait n/4 sec
	sw		t1,LEDR(zero)		; Bot LEDs on
	call	Timer(zero)			; Wait n/4 sec
	sw		t0,LEDR(zero)		; Repeat two more times...
	call	Timer(zero)
	sw		t1,LEDR(zero)
	call	Timer(zero)
	sw		t0,LEDR(zero)
	call	Timer(zero)
	sw		t1,LEDR(zero)
	call	Timer(zero)
	br		LEDRLoop			; Reset to State 1

; Reset the timer and loop until n/4 seconds have passed, meanwhile handle KEY presses
Timer:
	sw		zero,TCNT(zero)		; Reset timer
TimerLoop1:
	lw		a3,KEY(zero)		; Read KEY state
	beq		a3,s2,TimerLoop2	; If KEY state hasn't changed, skip to TimerLoop2
	beq		a3,s0,Key0			; If current KEY state == KEY[0], skip to Key0
	beq		a3,s1,Key1			; If current KEY state == KEY[1], skip to Key1
	beq		a3,zero,TimerLoop2	; Ignore KEY release and skip to TimerLoop2
	br		TimerLoop2			; Skip to TimerLoop2 if any other KEY was pressed
Key0:
	bgt		a1,fp,TimerLoop2	; If n > 7, then skip to TimerLoop2
	addi	a1,a1,0x1000		; Increment n and display on HEX[3]
	sw		a1,HEX(zero)
	addi	a0,a0,DLTA			; Increase blinking speed
	br		TimerLoop2			; Continue to rest of timer loop
Key1:
	beq		a1,sp,TimerLoop2	; If n == 1, then skip to TimerLoop2
	subi	a1,a1,0x1000		; Decrement n and display on HEX[3]
	sw		a1,HEX(zero)
	subi	a0,a0,DLTA			; Decrease blinking speed
TimerLoop2:
	add		s2,a3,zero			; Update previous KEY state
	lw		a2,TCNT(zero)		; Read timer count
	blt		a2,a0,TimerLoop1	; Loop while TCNT < timer target
	ret							; Return to LEDRLoop
