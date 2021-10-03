/*
 * apple_extended_keybaord_2_usb.cpp
 *  Example for SimpleAdb library
 *    Convert Apple Extended Keyboard II to USB
 *
 *  Created on: 2013/01/22
 *      Author: Y.S / JSL
 *    Hp:   blog.jomon-lab.com
 *    Mail:  blog_admin@jomon-lab.com
 *
 *  Modified by NeoCat <neocat@neocat.jp>
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of either the GNU General Public License version 2
 * or the GNU Lesser General Public License version 2.1, both as
 * published by the Free Software Foundation.
 *
 * This library is distributed  WITHOUT ANY WARRANTY
 *
 */
#include <Arduino.h>
#include <Keyboard.h>
#include <protocol.h>
#include <SimpleAdb.h>

const int adb_IO = 11;
const int led_IO = 13;

byte mapKey(byte keyCode) {
  byte   key;

  switch (keyCode) {
  case 0x35:
    key = KEY_ESC;          // esc 0xB0
    break;
  case 0x12:
    key = '1';
    break;
  case 0x13:
    key = '2';
    break;
  case 0x14:
    key = '3';
    break;
  case 0x15:
    key = '4';
    break;
  case 0x17:
    key = '5';
    break;
  case 0x16:
    key = '6';
    break;
  case 0x1A:
    key = '7';
    break;
  case 0x1C:
    key = '8';
    break;
  case 0x19:
    key = '9';
    break;
  case 0x1D:
    key = '0';
    break;
  case 0x1B:
    key = '-';
    break;
  case 0x18:
    key = '=';
    break;
  case 0x33:
    key = KEY_BACKSPACE;        // del 0xB2
    break;
  case 0x47:
    key = KEY_DELETE;          // clear 0xD4
    break;
  case 0x51:
    key = '=';               // keypad =
    break;
  case 0x4B:                 // keypad /
    key = 220;
    break;
  case 0x43:                 // keypad *
    key = 221;
    break;
  case 0x30:
    key = KEY_TAB;            // tab 0xB3
    break;
  case 0x0C:
    key = 'q';
    break;
  case 0x0D:
    key = 'w';
    break;
  case 0x0E:
    key = 'e';
    break;
  case 0x0F:
    key = 'r';
    break;
  case 0x11:
    key = 't';
    break;
  case 0x10:
    key = 'y';
    break;
  case 0x20:
    key = 'u';
    break;
  case 0x22:
    key = 'i';
    break;
  case 0x1F:
    key = 'o';
    break;
  case 0x23:
    key = 'p';
    break;
  case 0x21:
    key = '[';
    break;
  case 0x1E:
    key = ']';
    break;
  case 0x24:
    key = KEY_RETURN;          // return 0xB0
    break;
  case 0x59:
    key = 231;              // keypad 7
    break;
  case 0x5B:
    key = 232;              // keypad 8
    break;
  case 0x5C:
    key = 233;              // keypad 9
    break;
  case 0x45:
    key = 223;              // keypad +
    break;
  case 0x36:
    key = KEY_LEFT_CTRL;        // control 0x80
    break;
  case 0x00:
    key = 'a';
    break;
  case 0x01:
    key = 's';
    break;
  case 0x02:
    key = 'd';
    break;
  case 0x03:
    key = 'f';
    break;
  case 0x05:
    key = 'g';
    break;
  case 0x04:
    key = 'h';
    break;
  case 0x26:
    key = 'j';
    break;
  case 0x28:
    key = 'k';
    break;
  case 0x25:
    key = 'l';
    break;
  case 0x29:
    key = ';';
    break;
  case 0x27:
    key = 0x27;              // '
    break;
  case 0x56:
    key = 228;              // keypad 4
    break;
  case 0x57:
    key = 229;              // keypad 5
    break;
  case 0x58:
    key = 230;              // keypad 6
    break;
  case 0x4E:
    key = 222;              // keypad -
    break;
  case 0x38:
    key = KEY_LEFT_SHIFT;        // shift 0x81
    break;
  case 0x06:
    key = 'z';
    break;
  case 0x07:
    key = 'x';
    break;
  case 0x08:
    key = 'c';
    break;
  case 0x09:
    key = 'v';
    break;
  case 0x0B:
    key = 'b';
    break;
  case 0x2D:
    key = 'n';
    break;
  case 0x2E:
    key = 'm';
    break;
  case 0x2B:
    key = ',';
    break;
  case 0x2F:
    key = '.';
    break;
  case 0x2C:
    key = '/';
    break;
  case 0x53:
    key = 225;              // keypad 1
    break;
  case 0x54:
    key = 226;              // keypad 2
    break;
  case 0x55:
    key = 227;              // keypad 3
    break;
  case 0x4C:
    key = 224;          // keypad(enter) 0xB0
    break;
  case 0x39:
    key = KEY_CAPS_LOCK;        // lock 0xC1
    break;
  case 0x3A:
    key = KEY_LEFT_ALT;          // option(left alt) 0x82
    break;
  case 0x37:
    key = KEY_LEFT_GUI;          // command(left gui) 0x83
    break;
  case 0x32:
    key = '`';
    break;
  case 0x31:
    key = ' ';
    break;
  case 0x2A:
    key = '\\';
    break;
  case 0x3B:
    key = KEY_LEFT_ARROW;        // left 0xD8
    break;
  case 0x3C:
    key = KEY_RIGHT_ARROW;        // right 0xD7
    break;
  case 0x3D:
    key = KEY_DOWN_ARROW;        // down 0xD9
    break;
  case 0x3E:
    key = KEY_UP_ARROW;          // up 0xDA
    break;
  case 0x52:
    key = 234;              // keypad 0
    break;
  case 0x41:
    key = 235;              // keypad .
    break;
  case 0x7F:
    key = KEY_F16;        // powerkey
    break;
  case 0x66:
    key = 0;              // eisu(m0487)
    break;
  case 0x68:
    key = 0;              // kana(m0487)
    break;
  case 0x6A:
    key = KEY_RIGHT_ALT;        // enter(m0487) (right option) 0x86
    break;
//  case 0x18:
//    key = 0;              // ~(m0487)
//    break;
  case 0x5D:
    key = '`';              // |(m0487)
    break;
  case 0x5E:
    key = '_';              // _(m0487)
    break;
  case 0x7A:
    key = KEY_F1;            // (m0115) 0xC2
    break;
  case 0x78:
    key = KEY_F2;            // (m0115) 0xC3
    break;
  case 0x63:
    key = KEY_F3;            // (m0115) 0xC4
    break;
  case 0x76:
    key = KEY_F4;            // (m0115) 0xC5
    break;
  case 0x60:
    key = KEY_F5;            // (m0115) 0xC6
    break;
  case 0x61:
    key = KEY_F6;            // (m0115) 0xC7
    break;
  case 0x62:
    key = KEY_F7;            // (m0115) 0xC8
    break;
  case 0x64:
    key = KEY_F8;            // (m0115) 0xC9
    break;
  case 0x65:
    key = KEY_F9;            // (m0115) 0xCA
    break;
  case 0x6D:
    key = KEY_F10;            // (m0115) 0xCB
    break;
  case 0x67:
    key = KEY_F11;            // (m0115) 0xCC
    break;
  case 0x6F:
    key = KEY_F12;            // (m0115) 0xCD
    break;
  case 0x69:
    key = KEY_F13;              // (m0115) F13
    break;
  case 0x6B:
    key = KEY_F14;              // (m0115) F14
    break;
  case 0x71:
    key = KEY_F15;              // (m0115) F15
    break;
  case 0x72:
    key = KEY_INSERT;          // (m0115) 0xD1
    break;
  case 0x73:
    key = KEY_HOME;            // (m0115) 0xD2
    break;
  case 0x74:
    key = KEY_PAGE_UP;          // (m0115) 0xD3
    break;
  case 0x75:
    key = KEY_DELETE;          // (m0115) 0xD4
    break;
  case 0x77:
    key = KEY_END;            // (m0115) 0xD5
    break;
  case 0x79:
    key = KEY_PAGE_DOWN;        // (m0115) 0xD6
    break;
  default:
    key=0;
    break;
  }

  return key;
}

// The setup() method runs once, when the sketch starts
void setup()   {
  byte  adbCmd;

  // initialize the digital pin as an output:
  pinMode(adb_IO, OUTPUT);
  Serial.begin(115200);
  Keyboard.begin();
  Keyboard.releaseAll();
  adbCmd = KBD | TALK | REG0;          // ADB command send to target device
  SimpleAdb.begin(adbCmd);
  delay(2000);
}

bool caps_key_rel = false;

void loop() {
  byte    keyCode[2];
  byte    key;                  // key code input
  byte    state;                // key is down or up
  int     keyCnt;

  delay(10);
  if (caps_key_rel) {
    delay(80);
    Keyboard.release(KEY_CAPS_LOCK);
    caps_key_rel = false;
    return;
  }

  while (SimpleAdb.available()>0) {
    SimpleAdb.getKeyCode(&keyCode[0]);            // get raw key code (2 bytes)
    for (keyCnt=0;keyCnt<=1;keyCnt++) {
      if (keyCode[keyCnt]==0xff && keyCnt==1) {
        // skip 2nd byte if 0xff
      } else {
        // Serial.println(keyCode[keyCnt], HEX);
        if (keyCode[keyCnt]>=0x80) {
          key = mapKey(keyCode[keyCnt] & 0x7F);
          state = 1;                  // key up
        } else {
          key = mapKey(keyCode[keyCnt] & 0x7F);
          state = 0;                  // key down
        }
        if (key!=0x00) {
          if (state==0) {                // key down
            if (key==KEY_CAPS_LOCK) {
              Keyboard.press(key);
              caps_key_rel = true;
            } else {                // key released
              Keyboard.press(key);
            }
          } else {                  // key up
            if (key==KEY_CAPS_LOCK) {
              Keyboard.press(key);
              caps_key_rel = true;
            } else {                  // key released
              Keyboard.release(key);
            }
          }
        }
      }
    }
  }
}
