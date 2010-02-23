// -------------------------------------------------------
// OBAvatarGroup.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "OBAvatarGroup.h"
#import "OBConnector.h"
#import "OBRequest.h"
#import "OBUser.h"
#import "OBUtils.h"

@interface OBAvatarGroup ()
- (void) completeAvatarRequestForUser: (OBUser *) user withImageData: (NSData *) data;
- (void) decreaseUserCount;
@end

@implementation OBAvatarGroup

@synthesize messages, request;
OnDeallocRelease(messages, request, connector);

- (id) initWithMessages: (NSArray *) messageList
                request: (OBRequest *) obrequest
              connector: (OBConnector *) obconnector {  
  self = [super init];
  if (self) {
    messages = [messageList retain];
    request = [obrequest retain];
    connector = [obconnector retain];
  }
  return self;
}

- (void) loadAvatars {
  NSArray *uniqueUsers = [messages valueForKeyPath: @"@distinctUnionOfObjects.user"];
  NSPredicate *noAvatarFilter = [NSPredicate predicateWithFormat: @"avatar == NIL"];
  NSArray *usersWithoutAvatars = [uniqueUsers filteredArrayUsingPredicate: noAvatarFilter];
  userCount = usersWithoutAvatars.count;

  if (userCount > 0) {
    NSLog(@"got %d avatars, loading them...", userCount);
    for (OBUser *user in usersWithoutAvatars) {
      [[connector avatarInfoRequestForUser: user] sendFor: self];
    }
  } else {
    // all users already have avatars, problem solved
    [connector avatarGroupLoaded: self];
  }
}

- (void) avatarInfoNotFoundForUser: (OBUser *) user {
  NSLog(@"info not found for user %@", user.login);
  [self completeAvatarRequestForUser: user withImageData: [OBUser defaultAvatarData]];
}

- (void) avatarInfoLoadedForUser: (OBUser *) user path: (NSString *) path {
  NSLog(@"info loaded for user %@", user.login);
  [[connector avatarImageRequestForUser: user toPath: path] sendFor: self];
}

- (void) avatarImageLoadedForUser: (OBUser *) user data: (NSData *) data {
  NSLog(@"image loaded for user %@", user.login);
  [self completeAvatarRequestForUser: user withImageData: data];
}

- (void) requestFailedWithError: (NSError *) error {
  // couldn't load that avatar, ignore it
  NSLog(@"error, whatever");
  [self decreaseUserCount];
}

- (void) decreaseUserCount {
  NSLog(@"user %d -> %d", userCount, userCount-1);
  userCount--;
  if (userCount == 0) {
    NSLog(@"over");
    // all avatars have been downloaded
    [connector avatarGroupLoaded: self];
  }
}

- (void) completeAvatarRequestForUser: (OBUser *) user withImageData: (NSData *) data {
  [user setAvatarData: data];
  [self decreaseUserCount];
}

@end
