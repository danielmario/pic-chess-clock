	include	p16f630.inc
	processor	p16f630
	__CONFIG	_FOSC_INTRCIO & _MCLRE_OFF & _WDTE_OFF & _BODEN_OFF & _PWRTE_ON
	radix	dec
	extern	isr
	global	digits,flags,timer,p1_min,p1_sec,p1_ms,p2_min,p2_sec,p2_ms

	udata_shr
timer	res	1
flags	res	1	; sw3, sw2, sw1, buzz
digits	res	4
set_m	res	1
set_s	res	1
p1_min	res	1
p1_sec	res	1
p1_ms	res	1
p2_min	res	1
p2_sec	res	1
p2_ms	res	1
x	res	1
y	res	1
z	res	1
sw1	res	1
sw2	res	1
sw3	res	1

#define	BUZZ	PORTA,2
#define	TICK	PORTA,4
#define	P_LED	PORTA,5
#define	PLAYER	flags,5
#define	TIMEUP	flags,6
	
	code

decode_segment
	addlw	(256-16)
	btfsc	STATUS,C
	retlw	0xFF
	addlw	16
	addwf	PCL,f
	retlw	b'00000101'	; 0
	retlw	b'11011101'	; 1
	retlw	b'01000110'	; 2
	retlw	b'01010100'	; 3
	retlw	b'10011100'	; 4
	retlw	b'00110100'	; 5
	retlw	b'00100100'	; 6
	retlw	b'01011101'	; 7
	retlw	b'00000100'	; 8
	retlw	b'00010100'	; 9
	retlw	b'00001100'	; A
	retlw	b'10100100'	; b
	retlw	b'00100111'	; C
	retlw	b'11000100'	; d
	retlw	b'00100110'	; E
	retlw	b'00101110'	; f
	retlw	b'11111111'	;  

debounce	macro	port,bit,sw
	bcf	flags,bit
	rlf	sw,f
	bcf	sw,0
	btfsc	port,bit
	bsf	sw,0
	movlw	128
	addwf	sw,w
	btfsc	STATUS,Z
	bsf	flags,bit
	call	delay
	endm

delay
	movlw	5
	movwf	x
	clrf	y
	decfsz	y,f
	goto	$-1
	decfsz	x,f
	goto	$-4
	return

buzz
	movwf	y
buzz_loop1
	clrf	x
buzz_loop
	btfss	x,5
	bcf	BUZZ
	btfsc	x,5
	bsf	BUZZ
	incfsz	x,f
	goto	buzz_loop
	decfsz	y,f
	goto	buzz_loop1
	bsf	BUZZ
	return

decode_t	macro	t,a,b
	clrf	x
	movf	t,w
	incf	x,f
	addlw	(256-10)
	btfsc	STATUS,C
	goto	$-3
	addlw	10
	call	decode_segment
	movwf	digits+b
	decf	x,w
	call	decode_segment
	movwf	digits+a
	endm

main
	clrf	PORTA
	clrf	PORTC
	clrf	flags
	clrf	sw1
	clrf	sw2
	clrf	sw3
	clrf	digits
	clrf	digits+1
	clrf	digits+2
	clrf	digits+3
	clrwdt
	clrf	TMR0

	bsf	STATUS,RP0	; bank 1
	movlw	b'001011'
	movwf	TRISA
	clrf	TRISC
	bsf	PIE1,TMR1IE
	movlw	b'00000011'
	movwf	OPTION_REG

	bcf	STATUS,RP0	; bank 0
	movlw	b'00000111'
	movwf	CMCON
	movlw	b'00110100'
	movwf	T1CON
	movlw	b'11100000'
	movwf	INTCON

	movlw	3
	movwf	set_m
	clrf	set_s
setup
	bsf	TIMEUP
	bsf	BUZZ
	bcf	TICK
	movlw	0
	call	decode_segment
	movwf	digits+2
	movwf	digits+3
setup_loop
	decode_t	set_m,0,1

	debounce	PORTA,0,sw1
	debounce	PORTA,1,sw2
	debounce	PORTA,3,sw3
	
	btfsc	flags,0
	incf	set_m,f

	btfsc	flags,1
	decf	set_m,f

	movf	set_m,f
	movlw	1
	btfsc	STATUS,Z
	movwf	set_m

	movlw	(256-99)
	addwf	set_m,w
	movlw	1
	btfsc	STATUS,C
	movwf	set_m

	btfss	flags,3
	goto	setup_loop

setup_f
	bsf	TICK
	movlw	0xF
	call	decode_segment
	movwf	digits
	movlw	255
	movwf	digits+1

setup_f_loop
	decode_t	set_s,2,3

	debounce	PORTA,0,sw1
	debounce	PORTA,1,sw2
	debounce	PORTA,3,sw3
	
	btfsc	flags,0
	incf	set_s,f

	btfsc	flags,1
	decf	set_s,f

	movlw	(256-99)
	addwf	set_s,w
	btfsc	STATUS,C
	clrf	set_s

	btfss	flags,3
	goto	setup_f_loop

	movf	set_m,w
	movwf	p1_min
	movwf	p2_min
	clrf	p1_sec
	clrf	p2_sec
	clrf	p1_ms
	clrf	p2_ms

	movlw	254
	movwf	digits+0
	movwf	digits+1
	movwf	digits+2
	movwf	digits+3
setup_p
	debounce	PORTA,0,sw1
	debounce	PORTA,1,sw2
	debounce	PORTA,3,sw3

	btfsc	flags,3
	goto	setup

	btfss	flags,0
	goto	$+7

	movlw	20
	call	buzz
	bcf	TIMEUP
	bcf	PLAYER
	bcf	P_LED
	goto	player2

	btfss	flags,1
	goto	setup_p
	
	movlw	20
	call	buzz
	bcf	TIMEUP
	bsf	PLAYER
	bsf	P_LED
;	goto	player1

player1
	decode_t	p1_min,0,1
	decode_t	p1_sec,2,3

	btfsc	TIMEUP
	goto	endgame

	debounce	PORTA,0,sw1
	debounce	PORTA,3,sw3

	btfsc	flags,3
	goto	setup

	btfss	flags,0
	goto	player1
	
	movf	set_s,w
	addwf	p1_sec,f
	movf	p1_sec,w
	addlw	(256-60)
	btfss	STATUS,C
	goto	$+5
	movlw	60
	subwf	p1_sec,f
	incf	p1_min,f
	goto	$-7

	movlw	20
	call	buzz

	bcf	PLAYER
	bcf	P_LED
	goto	player2

player2
	decode_t	p2_min,0,1
	decode_t	p2_sec,2,3

	btfsc	TIMEUP
	goto	endgame

	debounce	PORTA,1,sw2
	debounce	PORTA,3,sw3

	btfsc	flags,3
	goto	setup

	btfss	flags,1
	goto	player2
	
	movf	set_s,w
	addwf	p2_sec,f
	movf	p2_sec,w
	addlw	(256-60)
	btfss	STATUS,C
	goto	$+5
	movlw	60
	subwf	p2_sec,f
	incf	p2_min,f
	goto	$-7

	movlw	20
	call	buzz
	
	bsf	PLAYER
	bsf	P_LED
	goto	player1

endgame
	bcf	TICK
	movlw	255
	call	buzz
	call	buzz
endgame_loop
	debounce	PORTA,3,sw3
	btfss	flags,3
	goto	endgame_loop
	goto	setup

; reset vector
	org	0	; reset
	goto	main

	org	4	; isr
	goto	isr

	end
