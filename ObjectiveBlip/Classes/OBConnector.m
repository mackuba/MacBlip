// -------------------------------------------------------
// OBConnector.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Constants.h"
#import "OBAccount.h"
#import "OBAvatarGroup.h"
#import "OBConnector.h"
#import "OBDashboardMonitor.h"
#import "OBRequest.h"
#import "OBMessage.h"
#import "OBUser.h"
#import "PsiToolkit.h"

static OBConnector *sharedConnector;
static BOOL loggingEnabled;

@interface OBConnector ()
- (void) acceptNewMessages: (NSArray *) messages fromRequest: (OBRequest *) request;
- (OBRequest *) requestWithPath: (NSString *) path
                         method: (NSString *) method
                           text: (NSString *) text;
@end


@implementation OBConnector

@synthesize account, userAgent, autoLoadAvatars, initialDashboardFetch;

// -------------------------------------------------------------------------------------------
#pragma mark Initializers

+ (void) initialize {
  #ifdef DEBUG
    loggingEnabled = YES;
  #else
    loggingEnabled = NO;
  #endif
}

+ (OBConnector *) sharedConnector {
  if (!sharedConnector) {
    sharedConnector = [[OBConnector alloc] init];
  }
  return sharedConnector;
}

+ (BOOL) loggingEnabled {
  return loggingEnabled;
}

+ (void) setLoggingEnabled: (BOOL) enabled {
  loggingEnabled = enabled;
}

- (id) init {
  self = [super init];
  if (self) {
    currentRequests = [[NSMutableArray alloc] initWithCapacity: 5];
    avatarGroups = [[NSMutableArray alloc] initWithCapacity: 1];
    account = [[OBAccount alloc] init];
    lastMessageId = -1;
    initialDashboardFetch = 20;
    userAgent = BLIP_USER_AGENT;
    autoLoadAvatars = NO;
    autoLoadPictureInfo = YES;
  }
  return self;
}

- (id) initWithUsername: (NSString *) aUsername password: (NSString *) aPassword {
  self = [self init];
  if (self) {
    account.username = aUsername;
    account.password = aPassword;
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

- (OBRequest *) authenticateRequest {
  OBRequest *request = [self requestWithPath: @"/login" method: @"GET" text: nil];
  [request setDidFinishSelector: @selector(authenticationSuccessful:)];
  return request;
}

- (OBRequest *) dashboardRequest {
  NSString *path;
  if (lastMessageId > 0) {
    path = PSFormat(@"/dashboard/since/%d", lastMessageId);
  } else {
    path = PSFormat(@"/dashboard?limit=%d", initialDashboardFetch);
  }
  if (autoLoadPictureInfo) {
    NSString *separator = ([path rangeOfString: @"?"].location == NSNotFound) ? @"?" : @"&";
    path = PSFormat(@"%@%@%@", path, separator, @"include=pictures");
  }
  OBRequest *request = [self requestWithPath: path method: @"GET" text: nil];
  [request setDidFinishSelector: @selector(dashboardUpdated:)];
  return request;
}

- (OBRequest *) sendMessageRequest: (NSString *) message {
  NSString *content = PSFormat(@"{\"update\": {\"body\": %@}}", [message performSelector: @selector(yajl_JSONString)]);
  OBRequest *request = [self requestWithPath: @"/updates" method: @"POST" text: content];
  [request setDidFinishSelector: @selector(messageSent:)];
  return request;
}

- (OBRequest *) loadPictureRequest: (OBMessage *) message {
  NSString *imageUrl = [[message.pictures objectAtIndex: 0] objectForKey: @"url"];
  OBRequest *request = [self requestWithPath: imageUrl method: @"GET" text: nil];
  [request setDidFinishSelector: @selector(pictureLoaded:)];
  [request setUserInfo: PSDict(message, @"message")];
  return request;
}

- (OBRequest *) avatarInfoRequestForUser: (OBUser *) user {
  NSString *path = PSFormat(@"/users/%@/avatar", user.login);
  OBRequest *request = [self requestWithPath: path method: @"GET" text: nil];
  [request setDidFinishSelector: @selector(avatarInfoLoaded:)];
  [request setUserInfo: PSDict(user, @"user")];
  return request;
}

- (OBRequest *) avatarImageRequestForUser: (OBUser *) user toPath: (NSString *) path {
  OBRequest *request = [self requestWithPath: path method: @"GET" text: nil];
  [request setDidFinishSelector: @selector(avatarImageLoaded:)];
  [request setUserInfo: PSDict(user, @"user")];
  return request;
}

- (OBRequest *) requestWithPath: (NSString *) path
                         method: (NSString *) method
                           text: (NSString *) text {
  OBRequest *request = [[OBRequest alloc] initWithPath: path method: method text: text];
  [request addBasicAuthenticationHeaderWithUsername: account.username andPassword: account.password];
  [request addRequestHeader: @"User-Agent" value: userAgent];
  [request setDelegate: self];
  [request autorelease];
  [currentRequests addObject: request];
  OBLog(@"sending %@ to %@ with '%@'", method, path, text);
  return request;
}

// -------------------------------------------------------------------------------------------
#pragma mark Response handling

- (void) logResponseToRequest: (id) request {
  NSString *contentType = [[request responseHeaders] objectForKey: @"Content-Type"];
  NSString *loggedText;
  if ([contentType hasPrefix: @"application/json"]) {
    loggedText = [request responseString];
  } else {
    loggedText = PSFormat(@"<Content-Type = %@, length = %d>", contentType, [[request responseData] length]);
  }
  OBLog(@"finished request to %@ (text = %@)", [request url], loggedText);
}

- (BOOL) isMrOponkaResponse: (id) request {
  NSString *locationHeader = [[request responseHeaders] objectForKey: @"Location"];
  if (!locationHeader) {
    locationHeader = @"";
  }
  NSRange errorFoundInUrl = [[[request url] absoluteString] rangeOfString: @"errors/blip"];
  NSRange errorFoundInHeader = [locationHeader rangeOfString: @"errors/blip"];
  return (errorFoundInUrl.location != NSNotFound) || (errorFoundInHeader.location != NSNotFound);
}

- (BOOL) handleFinishedRequest: (id) request {
  [self logResponseToRequest: request];
  [[request retain] autorelease];
  [currentRequests removeObject: request];

  if ([self isMrOponkaResponse: request]) {
    OBLog(@"Mr Oponka response detected");
    NSError *error = [NSError errorWithDomain: BLIP_ERROR_DOMAIN code: BLIP_ERROR_MR_OPONKA userInfo: nil];
    [[request target] requestFailedWithError: error];
    return NO;
  } else {
    return YES;
  }
}

- (void) authenticationSuccessful: (id) request {
  if (![self handleFinishedRequest: request]) return;

  account.loggedIn = YES;
  [[request target] authenticationSuccessful];
}

- (void) dashboardUpdated: (id) request {
  if (![self handleFinishedRequest: request]) return;

  NSString *trimmedString = [[request responseString] psTrimmedString];
  if (trimmedString.length > 0) {
    NSArray *messages = [OBMessage objectsFromJSONString: trimmedString];
    if (messages.count > 0) {
      // msgs are coming in the order from newest to oldest
      lastMessageId = [[messages objectAtIndex: 0] recordIdValue];
    }

    if (autoLoadAvatars) {
      OBAvatarGroup *group = [[OBAvatarGroup alloc] initWithMessages: messages request: request connector: self];
      [avatarGroups addObject: group];
      [group loadAvatars];
      [group release];
    } else {
      [self acceptNewMessages: messages fromRequest: request];
    }
  } else {
    [[request target] dashboardUpdatedWithMessages: [NSArray array]];
  }
}

- (void) avatarInfoLoaded: (id) request {
  if (![self handleFinishedRequest: request]) return;

  OBUser *user = [[request userInfo] objectForKey: @"user"];
  NSInteger status = [[[request responseHeaders] objectForKey: @"Status"] intValue];
  if (status == 404) {
    [[request target] avatarInfoNotFoundForUser: user];
  } else {
    NSString *trimmedString = [[request responseString] psTrimmedString];
    NSDictionary *avatarInfo = [trimmedString performSelector: @selector(yajl_JSON)];
    NSString *url50 = [avatarInfo objectForKey: @"url_50"];
    [[request target] avatarInfoLoadedForUser: user path: url50];
  }
}

- (void) avatarImageLoaded: (id) request {
  if (![self handleFinishedRequest: request]) return;

  OBUser *user = [[request userInfo] objectForKey: @"user"];
  [[request target] avatarImageLoadedForUser: user data: [request responseData]];
}

- (void) avatarGroupLoaded: (OBAvatarGroup *) group {
  [self acceptNewMessages: group.messages fromRequest: group.request];
  [avatarGroups removeObject: group];
}

- (void) acceptNewMessages: (NSArray *) messages fromRequest: (OBRequest *) request {
  [OBMessage prependObjectsToList: messages];
  [[request target] dashboardUpdatedWithMessages: messages];
}

- (void) messageSent: (id) request {
  if (![self handleFinishedRequest: request]) return;
  [[request target] messageSent];
}

- (void) pictureLoaded: (id) request {
  if (![self handleFinishedRequest: request]) return;

  NSData *pictureData = [request responseData];
  OBMessage *message = [[request userInfo] objectForKey: @"message"];
  [message setPictureData: pictureData];
  [[request target] pictureLoaded: pictureData forMessage: message];
}

- (void) requestFailed: (id) request {
  NSError *error = [request error];
  NSDictionary *userInfo = [error userInfo];
  NSMutableDictionary *updatedInfo = (userInfo) ?
    [NSMutableDictionary dictionaryWithDictionary: userInfo] : [NSMutableDictionary dictionaryWithCapacity: 1];
  [updatedInfo setObject: request forKey: @"request"];
  NSError *updatedError = [NSError errorWithDomain: error.domain code: error.code userInfo: updatedInfo];
  [[request target] requestFailedWithError: updatedError];
  [currentRequests removeObject: request];
}

- (void) authenticationNeededForRequest: (id) request {
  // TODO: let the user try again and reuse the connection
  [[request target] authenticationFailed];
  [request cancel];
  [currentRequests removeObject: request];
}

// -------------------------------------------------------------------------------------------
#pragma mark Cleaning up

- (void) cancelAllRequests {
  for (ASIHTTPRequest *request in currentRequests) {
    [request cancel];
  }
  [currentRequests removeAllObjects];
}

- (void) dealloc {
  [self cancelAllRequests];
  PSRelease(currentRequests, dashboardMonitor, account, userAgent, avatarGroups);
  [super dealloc];
}

@end
