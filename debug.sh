#!/bin/bash

gpsim -i debug.stc | grep '^0x' | perl debug.pl
