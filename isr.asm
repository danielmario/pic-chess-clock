	include	p16f630.inc
	processor	p16f630
	radix	dec

	extern	digits,flags,p1_min,p1_sec,p1_ms,p2_min,p2_sec,p2_ms
	global	isr

	udata_shr
dnext	res	1
x	res	1
y	res	1
z	res	1
s_w	res	1
s_fsr	res	1
s_st	res	1

; clock adjustment
#define ADJ     236

#define	TICK	PORTA,4
#define	PLAYER	flags,5
#define	TIMEUP	flags,6

#define	DAT	PORTC,3
#define	CLK	PORTC,4

	code

;   ;call does not work in interrupts?
;decode_index
;	addwf	PCL,f
;	retlw	b'100000'
;	retlw	b'000001'
;	retlw	b'000010'
;	retlw	b'000100'

isr
	; save context
	movwf	s_w
	swapf	STATUS,w
	movwf	s_st
	movf	FSR,w
	movwf	s_fsr

display
	; verify next digit and load into FSR
	movlw	3
	andwf	dnext,f
	movf	dnext,w
	addlw	digits
	movwf	FSR
	movf	INDF,w

	movwf	x
	movlw	8
	movwf	y

display_loop
	clrf	PORTC
	btfsc	x,0
	bsf	DAT
	bsf	CLK
	bcf	CLK
	rrf	x,f
	decfsz	y,f
	goto	display_loop

	; decode digit index (cannot call decode_index here)
	movf	dnext,w
	movwf	z
	; if z = 3, z = 4
	addlw	(0xFF-2)
	btfsc	STATUS,Z
	incf	z,f
	; if z = 0, z = 32
	movlw	32
	movf	z,f
	btfsc	STATUS,Z
	movwf	z
	movf	z,w
	movwf	PORTC
	incf	dnext,f

	btfsc	TIMEUP
	goto	t_end
	btfss	PLAYER
	goto	t_player2
t_player1
	bcf	TICK
	btfss	p1_sec,0
	bsf	TICK

	movf	p1_ms,f
	btfsc	STATUS,Z
	goto	$+3

	decf	p1_ms,f
	goto	t_end

	movf	p1_sec,f
	btfsc	STATUS,Z
	goto	$+5

	decf	p1_sec,f
	movlw	ADJ
	movwf	p1_ms
	goto	t_end

	movf	p1_min,f
	btfsc	STATUS,Z
	goto	$+7

	decf	p1_min,f
	movlw	59
	movwf	p1_sec
	movlw	ADJ
	movwf	p1_ms
	goto	t_end

	bsf	TIMEUP
	goto	t_end
t_player2
	bcf	TICK
	btfss	p2_sec,0
	bsf	TICK

	movf	p2_ms,f
	btfsc	STATUS,Z
	goto	$+3

	decf	p2_ms,f
	goto	t_end

	movf	p2_sec,f
	btfsc	STATUS,Z
	goto	$+5

	decf	p2_sec,f
	movlw	ADJ
	movwf	p2_ms
	goto	t_end

	movf	p2_min,f
	btfsc	STATUS,Z
	goto	$+7

	decf	p2_min,f
	movlw	59
	movwf	p2_sec
	movlw	ADJ
	movwf	p2_ms
	goto	t_end

	bsf	TIMEUP
t_end

	; clock adjustment 2
	nop
	movlw	2
	movwf	x
	decfsz	x,f
	goto	$-1

	clrf	TMR0
	bcf	INTCON,T0IF

	; restore context and return
	movf	s_fsr,w
	movwf	FSR
	swapf	s_st,w
	movwf	STATUS
	swapf	s_w,f
	swapf	s_w,w
	retfie

	end
