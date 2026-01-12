#!/usr/bin/env bash

swaylock \
  --daemonize \
  --screenshots \
  --effect-blur 9x7 \
  --effect-vignette 0.3:0.6 \
  --indicator \
  --indicator-radius 110 \
  --indicator-thickness 8 \
  --ring-color ffffff55 \
  --ring-ver-color ffffff88 \
  --ring-wrong-color ff555588 \
  --key-hl-color ffffff \
  --inside-color 00000099 \
  --inside-ver-color 00000099 \
  --inside-wrong-color 00000099 \
  --text-color ffffff \
  --clock \
  --timestr "%H:%M" \
  --datestr "%a %d %b"
