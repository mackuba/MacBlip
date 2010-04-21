#!/bin/bash
if [ -n "$1" ]; then
  ibtool --strings-file Views/Polish.lproj/$1.strings --write Views/Polish.lproj/$1.xib Views/English.lproj/$1.xib
else
  echo "Usage: $0 NibName"
fi
