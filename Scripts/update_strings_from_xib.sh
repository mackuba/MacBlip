#!/bin/bash
if [ -n "$1" ]; then
  ibtool --generate-strings-file Views/English.lproj/$1.strings Views/English.lproj/$1.xib
else
  echo "Usage: $0 NibName"
fi
