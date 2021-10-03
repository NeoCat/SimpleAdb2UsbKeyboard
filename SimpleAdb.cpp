/*
 * SimpleAdb.cpp
 *
 *  Created on: 2013/01/22
 *      Author: Y.S/JSL
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
#include	<Arduino.h>
#include	<avr/io.h>
#include	"SimpleAdb.h"

// Communication buffer
byte		ptrs[2];
byte		&wPtr = ptrs[0];							// write pointer
byte		&rPtr = ptrs[1];							// read pointer
byte		taBuf[256];								// type ahead buffer
byte		command;
byte		statusCmd;

ISR(TIMER3_COMPA_vect)
{
	simpleAdbProtocol(&taBuf[0], &wPtr, &command);
}

SimpleAdbClass SimpleAdb;

SimpleAdbClass::SimpleAdbClass() {
}

void SimpleAdbClass::begin(byte adbCmd) {
	if (((int)&wPtr) + 1 != (int)&rPtr) {
		delay(2000);
		Serial.println(F("Invalid addresses! check compile options"));
		Serial.println((int)&wPtr, HEX);
		Serial.println((int)&rPtr, HEX);
		for (;;);
	}
	rPtr = 0;
	wPtr = 0;
	sendAdbReset();
	initPollingTimer();
	command = adbCmd;								// ADB command send to target device
	sei();											// enable interrupt
	return;
}

void SimpleAdbClass::getKeyCode(byte	keyCode[]) {
	cli();
	keyCode[0] = taBuf[rPtr];
	rPtr++;
	keyCode[1] = taBuf[rPtr];
	rPtr++;
	sei();
	return ;
}

int SimpleAdbClass::available(void) {
	int		pendingCnt;

	cli();
	if (wPtr==rPtr) {
		pendingCnt = 0;
	} else if (wPtr>rPtr) {
		pendingCnt = wPtr - rPtr;
	} else {
		pendingCnt = wPtr + 256 - rPtr;
	}
	sei();
	return pendingCnt;
}
