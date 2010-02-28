// -------------------------------------------------------
// OBAvatarGroup.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

/*
  OBAvatarGroup - a group of users' avatars loaded together. It's created when a group of messages is received,
  then all matching avatars are loaded in parallel, and when all of them are ready, dashboard request can be completed.
*/


#import <Foundation/Foundation.h>

@class OBConnector;
@class OBRequest;
@class OBUser;

@interface OBAvatarGroup : NSObject {
  NSArray *messages;
  NSInteger userCount;
  OBRequest *request;
  OBConnector *connector;
}

@property (nonatomic, readonly) NSArray *messages;
@property (nonatomic, readonly) OBRequest *request;

- (id) initWithMessages: (NSArray *) messageList
                request: (OBRequest *) obrequest
              connector: (OBConnector *) obconnector;

- (void) loadAvatars;

- (void) avatarInfoNotFoundForUser: (OBUser *) user;
- (void) avatarInfoLoadedForUser: (OBUser *) user path: (NSString *) url;
- (void) avatarImageLoadedForUser: (OBUser *) user data: (NSData *) data;

@end
