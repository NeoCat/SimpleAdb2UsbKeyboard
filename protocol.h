/*
 * protocol.h
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

#ifndef ADB_IO_H_
#define ADB_IO_H_

#define	ADB_IO_PORT			PORTB
#define	ADB_DIRECTION_PORT	DDRB
#define	ADB_READ_PORT		PINB
#define	ADB_IO_BIT			PORTB7
#define	POLLING_TIMER		0xAC		// (1/16MHz) * 1024 * POLLING_TIMER = 11ms
//#define	POLLING_TIMER		0x68		// (1/16MHz) * 1024 * POLLING_TIMER = 6.6ms

#define	LED_PORT			PORTC
#define LED_BIT			PORTC7

#endif /* ADB_IO_H_ */
