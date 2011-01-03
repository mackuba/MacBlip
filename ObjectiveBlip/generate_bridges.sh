#!/bin/bash
DIR=`dirname $0`
ROOTDIR=`cd $DIR/..; pwd`
PSIDIR="$ROOTDIR/Lib/PsiToolkit"
if [ -n "$1" ]; then
  FILES="$1"
else
  FILES="$DIR/Classes/*.h $DIR/*.h"
fi
INCLUDES="-I$DIR -I$DIR/Classes -I$ROOTDIR/Lib/ASIHTTPRequest -I$PSIDIR/Models -I$PSIDIR/Network -I$PSIDIR/Security"
INCLUDES="$INCLUDES -include PSAccount.h -include PSConnector.h"

mkdir -p $DIR/Bridges

for file in $FILES
do
  gen_bridge_metadata -c "$INCLUDES" $file > $DIR/Bridges/`basename $file .h`.bridgesupport
  echo "Generated bridge for" `basename $file`
done
