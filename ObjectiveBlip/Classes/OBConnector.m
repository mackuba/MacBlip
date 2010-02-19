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
#import "OBUtils.h"
#import "NSString+BSJSONAdditions.h"

static OBConnector *sharedConnector;

@interface OBConnector ()
- (OBRequest *) requestWithPath: (NSString *) path
                         method: (NSString *) method
                           text: (NSString *) text;
@end


@implementation OBConnector

@synthesize account;

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

- (OBRequest *) requestWithPath: (NSString *) path
                         method: (NSString *) method
                           text: (NSString *) text {
  OBRequest *request = [[OBRequest alloc] initWithPath: path method: method text: text];
  [request addBasicAuthenticationHeaderWithUsername: account.username andPassword: account.password];
  [request setDelegate: self];
  [request autorelease];
  [currentRequests addObject: request];
  NSLog(@"sending %@ to %@ with '%@'", method, path, text);
  return request;
}

// -------------------------------------------------------------------------------------------
#pragma mark Response handling

- (void) handleFinishedRequest: (id) request {
  BOOL html = [[[request responseHeaders] objectForKey: @"Content-Type"] hasPrefix: @"text/html"];
  NSLog(@"finished request to %@ (text = %@)", [request url], html ? @"<...html...>" : [request responseString]);
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
    [OBMessage appendObjectsToList: messages];
    [[request target] dashboardUpdatedWithMessages: messages];
  } else {
    [[request target] dashboardUpdatedWithMessages: [NSArray array]];
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
  ReleaseAll(currentRequests, dashboardMonitor, account);
  [super dealloc];
}

@end
