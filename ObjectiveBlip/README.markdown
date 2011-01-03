# ObjectiveBlip

ObjectiveBlip is a Cocoa library that lets you connect to [blip.pl](http://blip.pl), Polish microblogging service,
via its REST API. It was extracted from [xBlip](http://github.com/psionides/xblip) project (prototype iPhone client for
Blip) and it's also used in [MacBlip](http://github.com/psionides/MacBlip) (MacOSX Blip client). You can use it to
create your own Blip clients in ObjectiveC/Cocoa if you want. It's pretty simple at the moment though, so don't expect
much...

## Setup instructions

* add the whole ObjectiveBlip directory to your Xcode project (the \*.bridgesupport files are only useful if you want
  to use a language other than ObjC, e.g. [MacRuby](http://macruby.org)
* install external dependencies:
  * [ASIHTTPRequest](http://allseeing-i.com/ASIHTTPRequest)
  * a JSON parser - [YAJL](http://github.com/gabriel/yajl-objc),
  [JSON Framework](http://stig.github.com/json-framework), [TouchJSON](https://github.com/schwa/TouchJSON)
  or [JSONKit](https://github.com/johnezang/JSONKit)
  * [PsiToolkit](http://github.com/psionides/PsiToolkit) with Models, Network and Security modules enabled
* import `ObjectiveBlip.h` somewhere, the best place is probably your `Prefix.pch` file

## Usage instructions

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
a `send` or `sendFor:callback:` method on the request. Use `sendFor:callback:` if you want the request to call a
callback method when it gets a response.

    // this will set blip.account.loggedIn to YES and then call authenticationSuccessful on self
    [[blip authenticateRequest] sendFor: self callback: @selector(authenticationSuccessful)];
    
    // this will only update messages, but won't call any callbacks
    [[blip dashboardRequest] send];

Note that every object that sets itself as the delegate using `sendFor:callback:` must be prepared to handle the
callbacks `authenticationFailedInRequest:` and `requestFailed:withError:` apart from the one that it expects.
OBConnector doesn't check if the receiver actually implements these two methods before the call.

To update the dashboard in regular intervals, use the OBDashboardMonitor class:

    [blip.dashboardMonitor setInterval: 15]; // default is 10 seconds
    [blip.dashboardMonitor startMonitoring];

This will start sending dashboard update requests every 15 seconds (unless there's already one in progress). When it
gets a response, it will send a OBDashboardUpdatedNotification via the NSNotificationCenter, with a list of new messages
(NSArray) in "messages" key in the userInfo hash of the notification. You can use the PSObserve() macro to subscribe to
this notification:

    PSObserve(blip.dashboardMonitor, OBDashboardUpdatedNotification, dashboardUpdatedWithMessages:);
    
    ...
    
    - (void) dashboardUpdatedWithMessages: (NSNotification *) notification {
      NSArray *messages = [notification.userInfo objectForKey: @"messages"];
      // ...
    }

OBDashboardMonitor also sends a notification when request is sent (OBDashboardWillUpdateNotification), and when a
request fails (OBDashboardUpdateFailedNotification).

Messages from the dashboard are stored in a global list accessible through OBMessage model:

    [OBMessage list]; // returns NSArray with all messages
    [OBMessage count]; // returns number of messages
    [OBMessage objectWithIntegerId: 123]; // returns specific message (lookup is fast since it uses a dictionary)

Some options that you may want to set on OBConnector:

* `autoLoadAvatars` - if on, it will first fetch all missing avatar images before answering to a dashboardRequest
  request (off by default)
* `userAgent` - your user agent string (default: ObjectiveBlip/0.x)
* `autoLoadPictureInfo` - if on, it will pass ?include=pictures to dashboard requests to include attached picture URLs;
  it's not a lot of data, but you can turn this off if you don't need pictures (default is on)
* `initialDashboardFetch` - how many messages will be loaded from the dashboard at first load (default: 20, max: 50)
* `loggingEnabled` - by default it's on when DEBUG is defined, the idea is that you can enable this setting only in
  debug mode, but not in release mode (in Xcode, add "-DDEBUG" to "Other C Flags" in the build properties of your
  target); you can also manually change this property according to e.g. user's settings. Warning: if this is enabled,
  OBConnector will print lots of boring shit so you really don't want this to be enabled by default in release mode.

For more info, check out the header file for OBConnector, and also docs and header for PSConnector from PsiToolkit
(of which OBConnector is a subclass).


## License

Copyright by Jakub Suder (Psionides) <jakub.suder at gmail.com>. Licensed under MIT license.
