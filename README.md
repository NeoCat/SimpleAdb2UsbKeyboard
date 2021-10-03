# ADB to USB adapter using Arduino Keyboard function

This Arduino library converts Apple Desktop Bus (ADB) keyboards to USB.

## Hardware

Supports Arduino Leonardo or compatible boards (such as Beetle) using ATmega32u4.

ADB female socket from the front:
```
  .-----.
 / o4 3o \      1: DATA
| o2   1o |     2: PSW (not connected)
 \   ■   /      3: VCC (5V)
  `-----'       4: GND
```

Pull up the DATA pin with a 1 - 10k Ohm register. Internal pull up will be too weak unless the Arduino board is connected directly to the keyboard.
DATA pin can be allocated to any IO pins (but no D13, which is connected to the on-board LED) by editing protocol.h and the sketch.

PSW pin is not used. (The power key can be handled in ADB protocol.)


Sample implementation using Beetle:

![Sample](https://pbs.twimg.com/media/FAIEwDaVcAE467S?format=jpg&name=small)


## Software

Import this library as Arduino library, and use Arduino IDE to write the example sketch to your Arduino board.

- apple_extended_keyboard_2_usb
  - Simply convert the Apple Extended Keyboard II to USB
- m0116
  - Convert M0116 keyboar with the CAPS lock as funciton key

## Original Author
Jomon System Laboratory

http://blog.jomon-lab.com/arduino-projects/adb-to-usb-adapter-using-arduino-keyboard-function
