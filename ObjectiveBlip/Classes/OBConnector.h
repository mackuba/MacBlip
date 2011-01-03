// -------------------------------------------------------
// OBConnector.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

/*
  OBConnector - the central class which manages everything related to Blip connection
*/

#import <Foundation/Foundation.h>

@class OBAccount, OBAvatarGroup, OBDashboardMonitor, OBMessage, OBShortLink, OBUser, PSRequest;

@interface OBConnector : PSConnector {
  NSInteger lastMessageId;
  NSMutableArray *avatarGroups;
  OBDashboardMonitor *dashboardMonitor;
  BOOL autoLoadAvatars;
  BOOL autoLoadPictureInfo;
  NSInteger initialDashboardFetch;
}

@property (nonatomic, readonly) OBDashboardMonitor *dashboardMonitor;
@property (nonatomic) BOOL autoLoadAvatars;
@property (nonatomic) NSInteger initialDashboardFetch;

- (id) init;
- (id) initWithUsername: (NSString *) username password: (NSString *) password;

- (PSRequest *) authenticateRequest;
- (PSRequest *) dashboardRequest;
- (PSRequest *) sendMessageRequest: (NSString *) message;
- (PSRequest *) loadPictureRequest: (OBMessage *) message;
- (PSRequest *) avatarImageRequestForUser: (OBUser *) user;
- (PSRequest *) shortenLinkRequest: (NSString *) link;
- (PSRequest *) expandLinkRequest: (OBShortLink *) link inMessage: (OBMessage *) message;

// internal
- (void) avatarGroupLoaded: (OBAvatarGroup *) group;

@end
