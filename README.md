PIC Chess Clock
===============

A simple chess game clock, written in PIC14 assembly for PIC16F630.
Porting to other PICs should not be a problem.

Inputs:

* PORTA,0: sw0, + 1 min / P1 to P2
* PORTA,1: sw1, - 1 min / P2 to P1
* PORTA,3: sw3,

Outputs:

* PORTA,5: leds
* PORTA,4: buzzer / display ":"
* PORTC: 4-digit 7-segment display

How to use:

* After power is on, press sw0 & sw1 to increase and decrease game time;
* press sw3 to configure Fischer-style delay;
* press sw0 & sw1 to increase or decrease time;
* press sw3 again, the display will read "----";
* one of the players must press her switch to start the opponent timer;
* That's it! Have fun.

Copyright (c) 2014, Daniel (tinyprog.github.io) under MIT License (see LICENSE).
