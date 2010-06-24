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
#import "PsiToolkit.h"

@interface OBAvatarGroup ()
- (void) completeAvatarRequestForUser: (OBUser *) user withImageData: (NSData *) data;
- (void) decreaseUserCount;
@end

@implementation OBAvatarGroup

@synthesize messages, request;
PSReleaseOnDealloc(messages, request, connector);

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
    OBLog(@"AvatarGroup: %d avatars are missing and will be loaded now.", userCount);
    for (OBUser *user in usersWithoutAvatars) {
      [[connector avatarImageRequestForUser: user] sendFor: self];
    }
  } else {
    // all users already have avatars, problem solved
    [connector avatarGroupLoaded: self];
  }
}

- (void) avatarImageLoadedForUser: (OBUser *) user data: (NSData *) data {
  [self completeAvatarRequestForUser: user withImageData: data];
}

- (void) requestFailedWithError: (NSError *) error {
  // couldn't load that avatar, ignore it
  [self decreaseUserCount];
}

- (void) authenticationFailed {
  // couldn't load that avatar, ignore it
  [self decreaseUserCount];
}

- (void) decreaseUserCount {
  userCount--;
  OBLog(@"AvatarGroup: %d avatars remaining", userCount);
  if (userCount == 0) {
    // all avatars have been downloaded
    [connector avatarGroupLoaded: self];
  }
}

- (void) completeAvatarRequestForUser: (OBUser *) user withImageData: (NSData *) data {
  [user setAvatarData: data];
  [self decreaseUserCount];
}

@end
