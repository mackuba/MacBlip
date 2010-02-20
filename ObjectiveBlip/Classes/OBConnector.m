// -------------------------------------------------------
// OBConnector.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Constants.h"
#import "OBAccount.h"
#import "OBConnector.h"
#import "OBDashboardMonitor.h"
#import "OBRequest.h"
#import "OBMessage.h"
#import "OBUser.h"
#import "OBUtils.h"
#import "NSDictionary+BSJSONAdditions.h"
#import "NSString+BSJSONAdditions.h"

static OBConnector *sharedConnector;

@interface OBConnector ()
- (void) acceptNewMessages: (NSArray *) messages fromRequest: (OBRequest *) request;
- (void) completeAvatarRequest: (id) request withImageData: (NSData *) image;
- (OBRequest *) requestWithPath: (NSString *) path
                         method: (NSString *) method
                           text: (NSString *) text;
@end


@implementation OBConnector

@synthesize account, userAgent, autoLoadAvatars;

// -------------------------------------------------------------------------------------------
#pragma mark Initializers

+ (OBConnector *) sharedConnector {
  if (!sharedConnector) {
    sharedConnector = [[OBConnector alloc] init];
  }
  return sharedConnector;
}

- (id) init {
  self = [super init];
  if (self) {
    currentRequests = [[NSMutableArray alloc] initWithCapacity: 5];
    account = [[OBAccount alloc] init];
    lastMessageId = -1;
    userAgent = BLIP_USER_AGENT;
    autoLoadAvatars = NO;
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
  NSString *path = (lastMessageId > 0) ? OBFormat(@"/dashboard/since/%d", lastMessageId) : @"/dashboard";
  OBRequest *request = [self requestWithPath: path method: @"GET" text: nil];
  [request setDidFinishSelector: @selector(dashboardUpdated:)];
  return request;
}

- (OBRequest *) sendMessageRequest: (NSString *) message {
  NSString *content = OBFormat(@"{\"update\": {\"body\": %@}}", [message jsonStringValue]);
  OBRequest *request = [self requestWithPath: @"/updates" method: @"POST" text: content];
  [request setDidFinishSelector: @selector(messageSent:)];
  return request;
}

- (OBRequest *) avatarInfoRequestForUser: (OBUser *) user {
  NSString *path = OBFormat(@"/users/%@/avatar", user.login);
  OBRequest *request = [self requestWithPath: path method: @"GET" text: nil];
  [request setDidFinishSelector: @selector(avatarInfoLoaded:)];
  return request;
}

- (OBRequest *) avatarImageRequestToPath: (NSString *) path {
  OBRequest *request = [self requestWithPath: path method: @"GET" text: nil];
  [request setDidFinishSelector: @selector(avatarImageLoaded:)];
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
  NSLog(@"sending %@ to %@ with '%@'", method, path, text);
  return request;
}

// -------------------------------------------------------------------------------------------
#pragma mark Response handling

- (void) handleFinishedRequest: (id) request {
  NSString *contentType = [[request responseHeaders] objectForKey: @"Content-Type"];
  NSString *loggedText;
  if ([contentType hasPrefix: @"application/json"]) {
    loggedText = [request responseString];
  } else {
    loggedText = OBFormat(@"<Content-Type = %@, length = %d>", contentType, [[request responseData] length]);
  }
  NSLog(@"finished request to %@ (text = %@)", [request url], loggedText);
  [[request retain] autorelease];
  [currentRequests removeObject: request];
}

- (void) authenticationSuccessful: (id) request {
  [self handleFinishedRequest: request];
  NSRange errorFound = [[[request url] absoluteString] rangeOfString: @"errors/blip"];
  if (errorFound.location == NSNotFound) {
    account.loggedIn = YES;
    [[request target] authenticationSuccessful];
  } else {
    NSError *error = [NSError errorWithDomain: BLIP_ERROR_DOMAIN code: BLIP_ERROR_MR_OPONKA userInfo: nil];
    [[request target] requestFailedWithError: error];
  }
}

- (void) dashboardUpdated: (id) request {
  [self handleFinishedRequest: request];
  NSString *trimmedString = [[request responseString] trimmedString];
  if (trimmedString.length > 0) {
    NSArray *messages = [OBMessage objectsFromJSONString: trimmedString];
    if (messages.count > 0) {
      // msgs are coming in the order from newest to oldest
      lastMessageId = [[messages objectAtIndex: 0] recordId];
    }

    if (autoLoadAvatars) {
      NSArray *users = [messages valueForKeyPath: @"@distinctUnionOfObjects.user"];
      NSPredicate *filter = [NSPredicate predicateWithFormat: @"avatar == NIL"];
      NSMutableArray *missing = [NSMutableArray arrayWithArray: [users filteredArrayUsingPredicate: filter]];
      if (missing.count > 0) {
        for (OBUser *user in missing) {
          OBRequest *avatarRequest = [self avatarInfoRequestForUser: user];
          [avatarRequest setUserInfo: OBDict(user, @"user", missing, @"allUsers", messages, @"messages")];
          [avatarRequest sendFor: [request target]];
        }
      } else {
        // all users already have avatars, problem solved
        [self acceptNewMessages: messages fromRequest: request];
      }
    } else {
      [self acceptNewMessages: messages fromRequest: request];
    }
  } else {
    [[request target] dashboardUpdatedWithMessages: [NSArray array]];
  }
}

- (void) acceptNewMessages: (NSArray *) messages fromRequest: (OBRequest *) request {
  [OBMessage addObjectsToBeginningOfList: messages];
  [[request target] dashboardUpdatedWithMessages: messages];
}

- (void) avatarInfoLoaded: (id) request {
  [self handleFinishedRequest: request];

  NSInteger status = [[[request responseHeaders] objectForKey: @"Status"] intValue];
  if (status == 404) {
    [self completeAvatarRequest: request withImageData: nil];
  } else {
    NSString *trimmedString = [[request responseString] trimmedString];
    NSDictionary *avatarInfo = [NSDictionary dictionaryWithJSONString: trimmedString];
    NSString *url = [avatarInfo objectForKey: @"url_50"];
    OBRequest *avatarRequest = [self avatarImageRequestToPath: url];
    [avatarRequest setUserInfo: [request userInfo]];
    [avatarRequest sendFor: [request target]];
  }
}

- (void) avatarImageLoaded: (id) request {
  [self handleFinishedRequest: request];
  NSData *imageData = [request responseData];
  [self completeAvatarRequest: request withImageData: imageData];
}

- (void) completeAvatarRequest: (id) request withImageData: (NSData *) data {
  OBUser *user = [[request userInfo] objectForKey: @"user"];
  NSMutableArray *allUsers = [[request userInfo] objectForKey: @"allUsers"];
  user.avatarData = data;
  [allUsers removeObject: user];
  if (allUsers.count == 0) {
    // all avatars have been downloaded
    [self acceptNewMessages: [[request userInfo] objectForKey: @"messages"] fromRequest: request];
  }
}

- (void) messageSent: (id) request {
  [self handleFinishedRequest: request];
  [[request target] messageSent];
}

- (void) requestFailed: (id) request {
  [[request target] requestFailedWithError: [request error]];
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
  ReleaseAll(currentRequests, dashboardMonitor, account, userAgent);
  [super dealloc];
}

@end
