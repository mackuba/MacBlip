# MacBlip

MacBlip is a MacOSX client for [Blip.pl](http://blip.pl), Polish microblogging service, written in MacRuby.

The ObjectiveBlip directory contains the backend code that handles the connection to Blip API. It's a separate
subproject, available at [http://github.com/psionides/ObjectiveBlip](http://github.com/psionides/ObjectiveBlip), and you
can use it to create your own Blip clients in ObjectiveC/Cocoa if you want (it's MIT-licensed).

## Features

* dashboard view
* sending messages
* displaying avatars
* growl notifications
* auto-update (Sparkle)

## Requirements

* Snow Leopard
* MacRuby (>= 0.5)

## License

Copyright by Jakub Suder <jakub.suder at gmail.com>. Licensed under GPL v3.
Includes open source libraries by Blake Seely (BSJSONAdditions), Ben Copsey (ASIHTTPRequest), and Steven Degutis.
