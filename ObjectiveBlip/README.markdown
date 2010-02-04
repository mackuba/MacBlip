# ObjectiveBlip

ObjectiveBlip is a Cocoa library that lets you connect to [blip.pl](http://blip.pl), Polish microblogging service,
via its REST API. It was extracted from [xBlip](http://github.com/psionides/xblip) project (iPhone client for Blip).
You can use it to create your own Blip clients in ObjectiveC/Cocoa if you want. It's pretty simple at the moment though,
so don't expect much...

Note: iPhone SDK 3.x is required.

## Setup instructions

* add a ObjectiveBlip directory to your project
* copy all \*.m and \*.h files from the ObjectiveBlip source tree to that directory
* create a new group "ObjectiveBlip" in your Xcode project; set its path to ObjectiveBlip directory (context menu -> "Get Info" -> path)
* add -> existing files -> select everything inside ObjectiveBlip directory
* add CFNetwork, SystemConfiguration and zlib (libz.1.2.3) frameworks to your project (follow the [ASIHTTPRequest documentation](http://allseeing-i.com/ASIHTTPRequest/Setup-instructions)
* optionally, change BLIP\_USER\_AGENT constant in Constants.h to a more suitable value
* for MacOSX apps, don't add the files Reachability.* and ASIAuthenticationDialog.* - they're iPhone-only and won't
compile with Mac version of Cocoa

## Usage instructions

To access ObjectiveBlip classes from your code, include this header:

    #import "ObjectiveBlip.h"

Most of the interaction with the server is done through an instance of the OBConnector class. First, create the
OBConnector and set a login and password:

    OBConnector *blip = [[OBConnector alloc] initWithUsername: username password: password];
    
    // or:
    
    OBConnector *blip = [[OBConnector alloc] init];
    blip.account.username = username;
    blip.account.password = password;
    
    // or use a single global connector:
    
    OBConnector *blip = [OBConnector sharedConnector];

Requests are made by generating a request object (OBRequest) by calling a method on the connector, and then calling
a `send` or `sendFor` method on the request. Use `sendFor` if you want the request to call a callback method when
it gets a response.

    // this will call authenticationSuccessful on self, and set blip.account.loggedIn to YES
    [[blip authenticateRequest] sendFor: self];
    
    // this will only update messages, but won't call any callbacks
    [[blip dashboardRequest] send];

To see the names of all the callback methods, look at the definition of OBConnectorDelegate in OBConnector.h
(you don't have to actually include this protocol in your classes).

To update the dashboard in regular intervals, use the OBDashboardMonitor class:

    [blip.dashboardMonitor setInterval: 15]; // default is 10 seconds
    [blip.dashboardMonitor startMonitoring];

This will start sending dashboard update requests every 15 seconds (unless there's already one in progress). When it
gets a response, it will send a OBDashboardUpdatedNotification via the NSNotificationCenter, with a list of new messages
(NSArray) in "messages" key in the userInfo hash of the notification. You can use the Observe() macro from OBUtils.h
to subscribe to this notification:

    Observe(blip.dashboardMonitor, OBDashboardUpdatedNotification, dashboardUpdatedWithMessages:);
    
    ...
    
    - (void) dashboardUpdatedWithMessages: (NSNotification *) notification {
      NSArray *messages = [notification.userInfo objectForKey: @"messages"];
      // ...
    }

Messages from the dashboard are stored in a global list accessible through OBMessage model:

    [OBMessage list]; // returns NSArray with all messages
    [OBMessage count]; // returns number of messages
    [OBMessage objectWithId: 123]; // returns specific message (lookup is fast since it's done through a dictionary)


## License

Copyright by Jakub Suder (Psionides) <jakub.suder at gmail.com>. Licensed under MIT license.
Includes open source libraries BSJSONAdditions by Blake Seely and ASIHTTPRequest by Ben Copsey.
