/*
 * SimpleAdb.h
 *
 *  Created on: 2013/01/20
 *      Author: Y.S / JSL
 *		Hp: 	blog.jomon-lab.com
 *		Mail:	blog_admin@jomon-lab.com
 *
 *	Modification history:
 *		V1.00:	2013/01/20	Initial release
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of either the GNU General Public License version 2
 * or the GNU Lesser General Public License version 2.1, both as
 * published by the Free Software Foundation.
 *
 * This library is distributed  WITHOUT ANY WARRANTY
 *
 */
#ifndef SIMPLEADB_H_
#define SIMPLEADB_H_
#include <Arduino.h>

// asm functions
extern "C" {
	void 	simpleAdbProtocol(byte *taBuf, byte *wPtr, byte *command);
	void	sendAdbReset(void);
	void	initPollingTimer(void);
}

// ADB command
#define LISTEN	0x08
#define TALK	0x0C

// ADB device address
#define KBD	0x20
#define MOUSE	0x30

// ADB device register
#define REG0	0x00
#define REG1	0x01
#define REG2	0x02
#define REG3	0x03

class SimpleAdbClass {
private:
public:
	SimpleAdbClass();
	void	begin(byte adbCmd);
	int		available(void);
	void 	getKeyCode(byte keyCode[]);
};
extern SimpleAdbClass SimpleAdb;

#endif /* SIMPLEADB_H_ */
