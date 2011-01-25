// -------------------------------------------------------
// OBAvatarGroup.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "OBAvatarGroup.h"
#import "OBConnector.h"
#import "OBUser.h"
#import "OBUtils.h"

@interface OBAvatarGroup ()
- (void) decreaseUserCount;
@end

@implementation OBAvatarGroup

@synthesize messages, request;
PSReleaseOnDealloc(messages, request, connector);

- (id) initWithMessages: (NSArray *) messageList
                request: (PSRequest *) psrequest
              connector: (OBConnector *) obconnector {  
  self = [super init];
  if (self) {
    messages = [messageList retain];
    request = [psrequest retain];
    connector = [obconnector retain];
  }
  return self;
}

- (void) loadAvatars {
  NSArray *uniqueUsers = [messages valueForKeyPath: @"@distinctUnionOfObjects.user"];
  NSArray *usersWithoutAvatars = [uniqueUsers psFilterWithPredicate: @"avatar == NIL"];
  userCount = usersWithoutAvatars.count;

  if (userCount > 0) {
    if (connector.loggingEnabled) {
      NSLog(@"AvatarGroup: %d avatars are missing and will be loaded now.", userCount);
    }
    for (OBUser *user in usersWithoutAvatars) {
      [[connector avatarImageRequestForUser: user] sendFor: self callback: @selector(avatarLoadedForUser:)];
    }
  } else {
    // all users already have avatars, problem solved
    [connector avatarGroupLoaded: self];
  }
}

- (void) avatarLoadedForUser: (OBUser *) user {
  [self decreaseUserCount];
}

- (void) requestFailed: (PSRequest *) request withError: (NSError *) error {
  // couldn't load that avatar, ignore it
  [self decreaseUserCount];
}

- (void) authenticationFailedInRequest: (PSRequest *) request {
  // couldn't load that avatar, ignore it
  [self decreaseUserCount];
}

- (void) decreaseUserCount {
  userCount--;
  if (connector.loggingEnabled) {
    NSLog(@"AvatarGroup: %d avatars remaining", userCount);
  }
  if (userCount == 0) {
    // all avatars have been downloaded
    [connector avatarGroupLoaded: self];
  }
}

@end
