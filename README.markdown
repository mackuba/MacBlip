# MacBlip

MacBlip is a MacOSX client for [Blip.pl](http://blip.pl), Polish microblogging service, written in MacRuby.

The ObjectiveBlip directory contains the backend code that handles the connection to Blip API. It's a separate
subproject, available at [http://github.com/jsuder/ObjectiveBlip](http://github.com/jsuder/ObjectiveBlip), and you
can use it to create your own Blip clients in ObjectiveC/Cocoa if you want (it's MIT-licensed).

## Features

* dashboard view
* sending messages
* displaying avatars and attached images
* growl notifications
* auto-update (Sparkle)

## Requirements

* Snow Leopard
* MacRuby (>= 0.10)
* 64-bit CPU (Core 2 Duo)

## License

Copyright by Jakub Suder <jakub.suder at gmail.com>. Licensed under Eclipse Public License v1.0.

Includes open source libraries: ASIHTTPRequest by Ben Copsey; SDListView, SDKVO and SDKeychain by Steven Degutis;
SBJson by Stig Brautaset; ImageCrop by Matt Gemmell; Sparkle by Andy Matuschak; and the Growl Framework.
