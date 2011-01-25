// -------------------------------------------------------
// OBConnector.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "OBAccount.h"
#import "OBAvatarGroup.h"
#import "OBConnector.h"
#import "OBDashboardMonitor.h"
#import "OBMessage.h"
#import "OBShortLink.h"
#import "OBUser.h"
#import "OBUtils.h"

@interface OBConnector ()
- (void) acceptNewMessages: (NSArray *) messages fromRequest: (PSRequest *) request;
@end


@implementation OBConnector

@synthesize autoLoadAvatars, initialDashboardFetch;
PSReleaseOnDealloc(dashboardMonitor, avatarGroups);

// -------------------------------------------------------------------------------------------
#pragma mark Initializers

+ (id) sharedConnector {
  id connector = [super sharedConnector];
  if (![connector isKindOfClass: [OBConnector class]]) {
    connector = [[[OBConnector alloc] init] autorelease];
    [self setSharedConnector: connector];
  }
  return connector;
}

- (id) init {
  self = [super init];
  if (self) {
    self.baseURL = BLIP_API_HOST;
    self.userAgent = BLIP_USER_AGENT;
    self.usesHTTPAuthentication = YES;
    self.account = [[OBAccount alloc] init];

    avatarGroups = [[NSMutableArray alloc] initWithCapacity: 1];
    lastMessageId = -1;
    initialDashboardFetch = 20;
    autoLoadAvatars = NO;
    autoLoadPictureInfo = YES;
  }
  return self;
}

- (id) initWithUsername: (NSString *) aUsername password: (NSString *) aPassword {
  self = [self init];
  if (self) {
    [account setUsername: aUsername];
    [account setPassword: aPassword];
  }
  return self;
}

- (OBDashboardMonitor *) dashboardMonitor {
  if (!dashboardMonitor) {
    dashboardMonitor = [[OBDashboardMonitor alloc] initWithConnector: self];
  }
  return dashboardMonitor;
}

// -------------------------------------------------------------------------------------------
#pragma mark Request sending

- (void) prepareRequest: (PSRequest *) request {
  [request addRequestHeader: @"X-Blip-API" value: BLIP_API_VERSION];
  request.timeOutSeconds = 15;
  request.shouldRedirect = NO;
}

- (PSRequest *) authenticateRequest {
  PSRequest *request = [self requestToPath: @"/login"];
  if (!request.username || !request.password) {
    // Blip API is stupid and returns the same response (redirect to /signin)
    // when you set correct authentication and when you set no authentication at all...
    request.username = request.password = @"anonymous";
  }
  request.successHandler = @selector(authenticationSuccessful:);
  request.expectedContentType = PSHTMLResponseType;
  return request;
}

- (PSRequest *) dashboardRequest {
  NSString *path = (lastMessageId == -1) ? @"/dashboard" : PSFormat(@"/dashboard/since/%d", lastMessageId);
  PSRequest *request = [self requestToPath: path];
  if (lastMessageId == -1) {
    [request addURLParameter: @"limit" integerValue: initialDashboardFetch];
  }
  if (autoLoadPictureInfo) {
    [request addURLParameter: @"include" value: @"pictures"];
  }
  request.successHandler = @selector(dashboardUpdated:);
  return request;
}

- (PSRequest *) sendMessageRequest: (NSString *) text {
  return [self createRequestForObject: [OBMessage messageWithBody: text]];
}

- (PSRequest *) loadPictureRequest: (OBMessage *) message {
  PSRequest *request = [self requestToURL: [message pictureURL]];
  request.successHandler = @selector(pictureLoaded:);
  request.expectedContentType = PSImageDataResponseType;
  request.userInfo = PSHash(@"message", message);
  return request;
}

- (PSRequest *) avatarImageRequestForUser: (OBUser *) owner {
  PSRequest *request = [self requestToPath: PSFormat(@"/users/%@/avatar/pico.jpg", owner.login)];
  request.successHandler = @selector(avatarImageLoaded:);
  request.expectedContentType = PSImageDataResponseType;
  request.userInfo = PSHash(@"owner", owner);
  return request;
}

- (PSRequest *) shortenLinkRequest: (NSString *) link {
  PSRequest *request = [self createRequestForObject: [OBShortLink shortLinkWithOriginalLink: link]];
  request.successHandler = @selector(linkShortened:);
  return request;
}

- (PSRequest *) expandLinkRequest: (OBShortLink *) link inMessage: (OBMessage *) message {
  PSRequest *request = [self showRequestForObject: link];
  request.successHandler = @selector(linkExpanded:);
  request.userInfo = PSHash(@"message", message);
  return request;
}

// -------------------------------------------------------------------------------------------
#pragma mark Response handling

- (void) checkResponseForErrors: (PSRequest *) request {
  NSString *url = [[request url] absoluteString];
  NSString *locationHeader = [[request responseHeaders] objectForKey: @"Location"];

  if (request.response.status == PSHTTPStatusNoContent) {
    // Blip can return this status with incorrect content type (text/plain) if there's no data
    return;
  }

  if ([url psContainsString: @"gadu-gadu.pl"] || [locationHeader psContainsString: @"gadu-gadu.pl"]) {
    NSLog(@"Mr Oponka response detected");
    NSLog(@"url = %@", url);
    NSLog(@"headers = %@", [request responseHeaders]);
    request.error = [NSError errorWithDomain: BLIP_ERROR_DOMAIN code: BLIP_ERROR_MR_OPONKA userInfo: nil];
    return;
  }

  [super checkResponseForErrors: request];
}

- (void) authenticationSuccessful: (PSRequest *) request {
  if ([self parseResponseFromRequest: request]) {
    [account setLoggedIn: YES];
    [request notifyTargetOfSuccess];
  }
}

- (void) dashboardUpdated: (PSRequest *) request {
  NSArray *messages = [self parseObjectsFromRequest: request model: [OBMessage class]];
  if (messages) {
    if ([messages isEqual: PSNull]) {
      messages = [NSArray array];
    }

    if (messages.count > 0) {
      // msgs are coming in the order from newest to oldest
      lastMessageId = [[messages psFirstObject] recordIdValue];
    }

    if (autoLoadAvatars && messages.count > 0) {
      OBAvatarGroup *group = [[OBAvatarGroup alloc] initWithMessages: messages request: request connector: self];
      [avatarGroups addObject: group];
      [group loadAvatars];
      [group release];
    } else {
      [self acceptNewMessages: messages fromRequest: request];
    }
  }
}

- (void) pictureLoaded: (PSRequest *) request {
  NSData *data = [self parseResponseFromRequest: request];
  if (data) {
    OBMessage *message = [request objectForKey: @"message"];
    [message setPictureData: data];
    [request notifyTargetOfSuccessWithObject: message];
  }
}

- (void) avatarImageLoaded: (PSRequest *) request {
  NSData *data = [self parseResponseFromRequest: request];
  if (data) {
    OBUser *owner = [request objectForKey: @"owner"];
    [owner setAvatarData: data];
    [request notifyTargetOfSuccessWithObject: owner];
  }
}

- (void) linkShortened: (PSRequest *) request {
  OBShortLink *shortlink = [self parseObjectFromRequest: request model: [OBShortLink class]];
  if (shortlink) {
    // we could just take what's in the response, but sometimes it returns e.g. Gazeta.pl when we ask for gazeta.pl...
    OBShortLink *previous = [request objectForKey: @"object"];
    [shortlink setOriginalLink: previous.originalLink];
    [request notifyTargetOfSuccessWithObject: shortlink];
  }
}

- (void) linkExpanded: (PSRequest *) request {
  OBShortLink *shortlink = [self parseObjectFromRequest: request model: [OBShortLink class]];
  if (shortlink) {
    OBMessage *message = [request objectForKey: @"message"];
    [request notifyTargetOfSuccessWithObject: PSHash(@"shortlink", shortlink, @"message", message)];
  }
}

- (void) avatarGroupLoaded: (OBAvatarGroup *) group {
  [self acceptNewMessages: group.messages fromRequest: group.request];
  [avatarGroups removeObject: group];
}

- (void) acceptNewMessages: (NSArray *) messages fromRequest: (PSRequest *) request {
  [OBMessage prependObjectsToList: messages];
  [request notifyTargetOfSuccessWithObject: messages];
}

@end
