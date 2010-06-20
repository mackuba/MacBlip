#!/bin/bash

MACRUBY_SYSTEM_PATH="/Library/Frameworks/MacRuby.framework/Versions/0.5/usr/lib/libmacruby.dylib"
MACRUBY_EMBEDDED_PATH="@executable_path/../Frameworks/MacRuby.framework/Versions/0.5/usr/lib/libmacruby.dylib"
APP_BUNDLE="build/Release/MacBlip.app"

echo "Compiling ruby files..."
macruby_deploy --compile $APP_BUNDLE

echo "Bundling MacRuby..."
macruby_deploy --embed --no-stdlib $APP_BUNDLE

echo "Done."
