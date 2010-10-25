#!/bin/bash

export ARCHS="i386 x86_64"

APP_BUNDLE="build/Release/MacBlip.app"

echo "Compiling ruby files..."
macruby_deploy --compile $APP_BUNDLE

echo "Bundling MacRuby..."
macruby_deploy --embed --no-stdlib $APP_BUNDLE

echo "Done."
