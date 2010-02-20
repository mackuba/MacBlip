// -------------------------------------------------------
// OBConnector.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@class OBAccount;
@class OBRequest;
@class OBDashboardMonitor;

// these callback methods will be called on objects that created the request
@protocol OBConnectorDelegate
- (void) authenticationSuccessful;
- (void) authenticationFailed;
- (void) messageSent;
- (void) dashboardUpdatedWithMessages: (NSArray *) messages;
- (void) requestFailedWithError: (NSError *) error;
@end

@interface OBConnector : NSObject {
  NSInteger lastMessageId;
  NSMutableArray *currentRequests;
  NSString *userAgent;
  OBDashboardMonitor *dashboardMonitor;
  OBAccount *account;
  BOOL autoLoadAvatars;
}

@property (nonatomic, retain) OBAccount *account;
@property (nonatomic, copy) NSString *userAgent;
@property (nonatomic, readonly) OBDashboardMonitor *dashboardMonitor;
@property (nonatomic) BOOL autoLoadAvatars;

+ (OBConnector *) sharedConnector;

- (id) init;
- (id) initWithUsername: (NSString *) username password: (NSString *) password;

- (OBRequest *) authenticateRequest;
- (OBRequest *) dashboardRequest;
- (OBRequest *) sendMessageRequest: (NSString *) message;

@end
