/*
 * protocol.S
 *
 *  Created on: 2013/01/22
 *      Author: Y.S / JSL
 *		Hp: 	blog.jomon-lab.com
 *		Mail:	blog_admin@jomon-lab.com
 *
 *	Modification history:
 *		V1.00:	2013/01/22	Initial release
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of either the GNU General Public License version 2
 * or the GNU Lesser General Public License version 2.1, both as
 * published by the Free Software Foundation.
 *
 * This library is distributed  WITHOUT ANY WARRANTY
 *
 */
#define _SFR_ASM_COMPAT 1
#define __SFR_OFFSET 0

#include <avr/io.h>
#include "protocol.h"

;	register definitions
	hundred	=	31						; constant value
	tmpVal	= 	30						; temporary storage
	p1		=	24						; parameter1 is in r24, r25
	p2		= 	22
	p3		=	20
	adbData	=	19						; data read/write from ADB
	bitCnt 	= 	18						; data bit count (0 to min 16, max 64)
	bitNo	=	17						; bit no in byte (8 to 1)
	counter	=	16						; clock counter
	bitVal 	=	15						; data bit value
	ptrWrt	= 	14						; write pointer
	ptrRead	=	13
	lowCnt	=	12						; low state count
	highCnt	=	11						; high state count
	cmd		= 	10						; adb commad
	zero	= 	1						; r1 always 0
	tmp		=	0						; temporary storage r0

;.section	.text

;	simpleAdbProtocol
;+++++++++++++++++++++++++++++++++++++++++++++++++++
;
;	1. send attension
;	2. send command
;	   if keyboard => 0x2c: KBD 0x20 + TALK 0x0c + register0 0x00
;	3. send stop
;	4. check SRQ	-> not implimented
;	5. check start	-> merged into next step
;	6. read data
;
;	input:
;		p1(r24, r25):	address of read buffer
;		p2(r22, r23):	address of ptrWrt
;		p3(r20, r21):	address of command
;	output:
;		none
;
;---------------------------------------------------
.global	simpleAdbProtocol
simpleAdbProtocol:
	push	bitNo							; the other registers are push/pop by ISR()
	push	counter
	push	bitVal
	push	ptrWrt
	push	ptrRead
	push	lowCnt
	push	highCnt
	push	cmd
;+++++++++++++++++++++++++++++++++++++++++++++++++++
;	Check buffer over flow
;	if taBuf is 90% full then skip polling
;		if ptrWrt > ptrRead
;		  if ptrWrt-ptrRead > 230 then skip polling
;		else
;		  if ptrRead-ptrWrt < 26 then skip polling
;---------------------------------------------------
	movw	XL, p2
	ld		ptrWrt, X
	ld		ptrRead, -X						; ptrRead -> X-1
	cp		ptrRead, ptrWrt
	breq	sendAtten						; start polling if ptrWrt = ptrRead
	brcs	ptrWrtIsGrater					; carry set if ptrWrt > ptrRead
ptrReadIsGreater:
	mov		tmpVal, ptrRead
	sub		tmpVal, ptrWrt					; ptrRead - ptrWrt
	cpi		tmpVal, 0x1a					; check if ptrRead-ptrWrt<26
	brcs	endProcessreadFromAdb			; then skip polling
	rjmp	sendAtten
ptrWrtIsGrater:
	mov		tmpVal, ptrWrt
	sub		tmpVal, ptrRead					; ptrWrt - ptrRead
	cpi		tmpVal, 0xe6					; check if ptrWrt-ptrRead>230
	brcc	endProcessreadFromAdb			; then skip polling
;+++++++++++++++++++++++++++++++++++++++++++++++++++
;	send attention
;---------------------------------------------------
sendAtten:
	sbi		ADB_DIRECTION_PORT, ADB_IO_BIT	; set for output
	rcall	sendAttention
;+++++++++++++++++++++++++++++++++++++++++++++++++++
;	send command
;---------------------------------------------------
sendCommand:
	ldi		counter, 0x08
	movw	YL, p3
	ld		cmd, Y
sendCommand1:
	lsl		cmd
	brcs	sendBitHigh
sendBitLow:
	ldi		adbData, 0x00
	rjmp	sendCommand2
sendBitHigh:
	ldi		adbData, 0x01
sendCommand2:
	rcall	sendBitToAdb
	dec		counter
	brne	sendCommand1
;++++++++++++++++++++++++++++++++++++++++++++++++++++
;	send stop
;----------------------------------------------------
sendStop:
	ldi		adbData, 0x00
	rcall	sendBitToAdb
;++++++++++++++++++++++++++++++++++++++++++++++++++++
;	check SRQ
;----------------------------------------------------
checkSrq:
	cbi		ADB_DIRECTION_PORT, ADB_IO_BIT	; set for input
	sbi		ADB_IO_PORT, ADB_IO_BIT			; enable pullup -> pullup register not enough ???
;	rcall	waitForSrq
;	cpi		p1, 0x01
;	brne	srqNotFound
waitForTlt:								; wait 160 usec
	ldi		counter, 0xa0					;
waitForTlt1:
	rcall	wait10clock						; 3 clk
	dec		counter							; 1 clk
	brne	waitForTlt1						; 2 clk
;++++++++++++++++++++++++++++++++++++++++++++++++++++
;	read data
;----------------------------------------------------
readStart:
;	rcall	waitForStart
;	cpi		p1, 0x00
;	breq	startNotFound
readData:
	rcall	waitForData
	cpi		p1, 0x00
	breq	dataNotFound
	rjmp	endProcessreadFromAdb
startNotFound:
	ldi		p1, 0x00
	rjmp	endProcessreadFromAdb
dataNotFound:
	ldi		p1, 0x00
	rjmp	endProcessreadFromAdb
endProcessreadFromAdb:
	pop		cmd
	pop		highCnt
	pop		lowCnt
	pop		ptrRead
	pop		ptrWrt
	pop		bitVal
	pop		counter
	pop		bitNo
	ret

;	sendAttention
;++++++++++++++++++++++++++++++++++++++++++++++++++++
;
;	send attention (Low pulse) to ADB
;
;----------------------------------------------------
.func	sendAttention
sendAttention:
	push	counter
	cbi		ADB_IO_PORT, ADB_IO_BIT			; make PD6 LOW
lowLongAttn:								; wait for 800 usec
	ldi		counter, 0xc8					; 1 clk
lowLongAttn1:								; 4 usec for 1 loop
	rcall	wait10clock						; 3 clk
	rcall	wait10clock						; 3 clk
	rcall	wait10clock						; 3 clk
	rcall	wait10clock						; 3 clk
	rcall	wait6clock						; 3 clk
	dec		counter							; 1 clk
	brne	lowLongAttn1					; 2 clk
	sbi		ADB_IO_PORT, ADB_IO_BIT
highShortAttn:							; wait for 66 usec
	ldi		counter, 0x42
highShortAttn1:
	rcall	wait10clock						; 3 clk
	dec		counter							; 1 clk
	brne	highShortAttn1					; 2 clk
	pop		counter
	ret
.endfunc

;	sendBitToAdb
;++++++++++++++++++++++++++++++++++++++++++++++++++++
;
;	send specified High/Low pulse to ADB
;
;	r18: bit value 0 or 1
;
;----------------------------------------------------
.func sendBitToAdb
sendBitToAdb:
	push	counter
	cbi		ADB_IO_PORT, ADB_IO_BIT			; make ADB_IO_BIT LOW
	cpi 	adbData, 0x01					; 1 clk
	brne	lowLong							; 1 clk
lowShort:									; wait for 33 usec
	ldi		counter, 0x21					; 1 clk
lowShort1:									; 1usec for 1 loop
	rcall	wait10clock						; 3 clk
	dec		counter							; 1 clk
	brne	lowShort1						; 2 clk
	sbi		ADB_IO_PORT, ADB_IO_BIT
highLong:									; wait for 66 usec
	ldi		counter, 0x42
highLong1:
	rcall	wait10clock						; 3 clk
	dec		counter							; 1 clk
	brne	highLong1						; 2 clk
	rjmp	endProcessSendBit
lowLong:									; wait for 66 usec
	ldi		counter, 0x42					; 1 clk
lowLong1:									; 1 usec for 1 loop
	rcall	wait10clock						; 3 clk
	dec		counter							; 1 clk
	brne	lowLong1						; 2 clk
	sbi		ADB_IO_PORT, ADB_IO_BIT
highShort:									; wait for 33 usec
	ldi		counter, 0x21					; 1 clk
highShort1:
	rcall	wait10clock						; 3 clk
	dec		counter							; 1 clk
	brne	highShort1						; 2 clk
endProcessSendBit:
	pop	counter
	ret
.endfunc

;	waitForSrq
;++++++++++++++++++++++++++++++++++++++++++++++++
;!!! not used now
;	wait for SRQ signal for 300 usec
;	return as soon as SRQ detected
;
;	return status:
;		1:	SRQ found
;		0:	SRQ timeout
;------------------------------------------------
;;.func	waitForSrq
;;waitForSrq:
;;	push	counter
;;	ldi		counter, 0x96					; wait for 150x2=300 usec
;;testADB_IO_BITSrq:						; test ADB_IO_BIT -> 2 usec for loop
;;	sbis	ADB_READ_PORT, ADB_IO_BIT		; 2 clk
;;	rjmp	findSrq							;
;;	rcall	wait10clock						; 3 clk
;;	rcall	wait10clock						; 3 clk
;;	nop
;;	dec		counter							; 1 clk
;;	brne	testADB_IO_BITSrq				; 2 clk
;;	rjmp	timeoutSrq
;;findSrq:
;;	sbis	ADB_READ_PORT, ADB_IO_BIT		; 2 clk
;;	rjmp	findSrq
;;	ldi		p1, 0x01
;;	rjmp	endProcSrq
;;timeoutSrq:
;;	ldi		p1, 0x00
;;endProcSrq:
;;	pop		counter
;;	ret
;;.endfunc

;	waitForStart
;++++++++++++++++++++++++++++++++++++++++++++++++
;!!! not used now
;
;	wait for Start signal for 300 usec
;	return as soon as Start detected
;
;	return status:
;		low duration:	Start found
;		0:				start not found
;		1:				start found, but too short
;------------------------------------------------
;;.func		waitForStart
;;waitForStart:
;;	push	counter
;;	ldi		counter, 0x96					; wait for 150x2=300 usec
;;testADB_IO_BITStart:						; test ADB_IO_BIT -> 2 usec for loop
;;	sbis	ADB_READ_PORT, ADB_IO_BIT		; 2 clk
;;	rjmp	findStart						;
;;	rcall	wait10clock						; 3 clk
;;	rcall	wait10clock						; 3 clk
;;	nop
;;	dec		counter							; 1 clk
;;	brne	testADB_IO_BITStart				; 2 clk
;;	rjmp	timeoutStart
;;findStart:
;;	ldi		counter, 0x01
;;findStart1:								; 1 usec for loop
;;	rcall	wait8clock						; 3 clk
;;	sbic	ADB_READ_PORT, ADB_IO_BIT		; 2 clk
;;	rjmp	endFindStart					;
;;	inc		counter							; 1 clk
;;	rjmp	findStart1						; 2 clk
;;endFindStart:
;;	mov		p1, counter						;
;;	rjmp	endProcStart
;;timeoutStart:
;;	ldi		p1, 0x00
;;endProcStart:
;;	pop		counter
;;	ret
;;.endfunc

;	waitForData
;++++++++++++++++++++++++++++++++++++++++++++++++
;
;	read data bits
;
;	return status:
;		p1: 			byte count
;		read buffer:	data read from KBD
;
;	stop bit will not included in bits count
;------------------------------------------------
.func		waitForData
waitForData:
	push	XL
	push	XH
	push	YL
	push	YH
	push	counter
	push	highCnt
	push	lowCnt
	push	bitCnt
	push	bitVal
	push	bitNo
	push	hundred
	push	ptrWrt

	ldi		hundred, 0x64					; hold 100
	movw	XL, p2
	ld		ptrWrt, X
	movw	YL, p1
	add		YL, ptrWrt
	adc		YH, zero
	mov		bitCnt, zero					; init bitCnt
	ldi		counter, 0x96					; wait for 150x2=300 usec
testADB_IO_BITdata:						; test ADB_IO_BIT -> 2 usec for loop
	sbis	ADB_READ_PORT, ADB_IO_BIT		; 2 clk
	rjmp	readNextByte					;
	rcall	wait10clock						; 3 clk
	rcall	wait10clock						; 3 clk
	nop										; 1 clk
	dec		counter							; 1 clk
	brne	testADB_IO_BITdata				; 2 clk
	rjmp	readTimeout
readNextByte:
	mov		bitVal, zero					; clear bitVal
	ldi		bitNo,	0x08					; init bit no
readNextBit:
	mov		lowCnt, zero
findLow:									; 1 usec for loop
	rcall	wait6clock						; 3 clk
	sbic	ADB_READ_PORT, ADB_IO_BIT		; 2 clk
	rjmp	endFindLow						;
	inc		lowCnt							; 1 clk
	cp		lowCnt, hundred					; 1 clk more than 100 usec
	brsh	lostBits						; 1 clk
	rjmp	findLow							; 2 clk
endFindLow:
	mov		highCnt, zero
findHigh:
	rcall	wait6clock						; 3 clk
	sbis	ADB_READ_PORT, ADB_IO_BIT		; 2 clk
	rjmp	endFindHigh						;
	inc		highCnt							; 1 clk
	cp		highCnt, hundred				; 1 clk more than 100 usec
	brsh	lostBits						; 1 clk
	rjmp	findHigh						; 2 clk
endFindHigh:
	cpi		bitCnt, 0x01					; 1 clk check if start bit
	brsh	checkBit						; 2 clk branch if bitCnt >= 1
	rjmp	endReadBit						; 2 clk skip start bit
checkBit:
	cp		lowCnt, highCnt					; 1 clk carry set if high > low
	rol		bitVal							; 1 clk shift carry bit into bitVal
	dec		bitNo							; 1 clk
	brne	endReadBit						; 2 clk
endReadByte:
	st		Y, bitVal						; 2 clk save key date into taBuf
	inc		bitCnt							; 1 clk inc bit count
	inc		ptrWrt							; 1 clk inc write pointer
	movw	YL, p1							; 1 clk
	add		YL, ptrWrt						; 1 clk
	adc		YH, zero							; 1 clk
	rjmp	readNextByte					; 2 clk
endReadBit:
	inc		bitCnt							; 1 clk inc bit count
	rjmp	readNextBit						; 2 clk read next bit
lostBits:
readTimeout:
endProcData:
	st		X, ptrWrt							; save write pointer
	pop		ptrWrt
	pop		hundred
	pop		bitNo
	pop		bitVal
	pop		bitCnt
	pop		lowCnt
	pop		highCnt
	pop		counter
	pop		YH
	pop		YL
	pop		XH
	pop		XL
	ret
.endfunc

;	sendAdbReset
;++++++++++++++++++++++++++++++++++++++++++++++++++++
;
;	send reset (Low pulse) to ADB
;
;----------------------------------------------------
.global	sendAdbReset
.func		sendAdbReset
sendAdbReset:
	push	counter
	cbi		ADB_IO_PORT, ADB_IO_BIT			; make PD6 LOW
lowLongRst:								; wait for 1000 usec
	ldi		counter, 0xfa					; 1 clk
lowLongRst1:								; 4 usec for 1 loop
	rcall	wait10clock						; 3 clk
	rcall	wait10clock						; 3 clk
	rcall	wait10clock						; 3 clk
	rcall	wait10clock						; 3 clk
	rcall	wait6clock						; 3 clk
	dec		counter							; 1 clk
	brne	lowLongRst1						; 2 clk
	sbi		ADB_IO_PORT, ADB_IO_BIT
highShortRst:								; wait for 66 usec
	ldi		counter, 0x42
highShortRst1:
	rcall	wait10clock						; 3 clk
	dec		counter							; 1 clk
	brne	highShortRst1					; 2 clk
	pop		counter
	ret
.endfunc

;++++++++++++++++++++++++++++++++++++++++++++++++++
;	delays
;--------------------------------------------------
.func	wait10clock
wait10clock:
	nop										; 1 clk
wait9clock:
	nop
wait8clock:
	nop
wait7clock:
	nop
wait6clock:
	nop
wait5clock:
	nop
wait4clock:
	ret										; 4 clk
.endfunc

;+++++++++++++++++++++++++++++++++++++++++++++++++++
;	Initialize polling timer
;		Timer/Counter3
;		prescaler = 1/1024
;		CompareMatch = 0xAC = 172
;		polling timer = 172 * 1024 / 16000000 = 11.008 ms
;---------------------------------------------------
.global	initPollingTimer
.func		initPollingTimer
initPollingTimer:
	push	r16
	push	XL
	push	XH
	; Set CTC mode (Clear Timer on Compare match )
	ldi		r16,0x00
	ldi		XL,lo8(TCCR3A)					; Timer/Counter3 Control Register A
	ldi		XH,hi8(TCCR3A)
	st		X,r16
	; Set CTC mode and prescaler = 1024
	ldi		r16,0x0d						;
	ldi		XL,lo8(TCCR3B)					; Timer/Counter3 Control Register B
	ldi		XH,hi8(TCCR3B)
	st		X,r16
	; Output Compare Register 1 A
	ldi		r16, 0x00
	ldi		XL,lo8(OCR3AH)					; Output Compare Register 3 A
	ldi		XH,hi8(OCR3AH)
	st		X,r16
	ldi		r16, POLLING_TIMER				; (1024 * 0xAC) / 16000000 = 11.36 ms
	ldi		XL,lo8(OCR3AL)					; Output Compare Register 3 A
	ldi		XH,hi8(OCR3AL)
	st		X,r16
	; Enable timer interrupt
	ldi		r16,1<<OCIE3A 					; Timer/Counter3 Output Compare A Match Interrupt Enable
	ldi		XL,lo8(TIMSK3)					; Timer/Counter3 Interrupt Mask Register
	ldi		XH,hi8(TIMSK3)
	st		X,r16
;	sei
	pop		XH
	pop		XL
	pop		r16
	ret
.endfunc
