// -------------------------------------------------------
// OBUser.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "OBUser.h"
#import "OBUtils.h"

static NSMutableDictionary *loginIndex;
static NSData *defaultAvatarData;

@implementation OBUser

@synthesize login, avatar, avatarData;
OnDeallocRelease(login, avatar, avatarData);

+ (void) initialize {
  loginIndex = [[NSMutableDictionary alloc] initWithCapacity: 100];
  defaultAvatarData = nil;
}

+ (OBUser *) findOrCreateByLogin: (NSString *) login {
  OBUser *user = [loginIndex objectForKey: login];
  if (!user) {
    user = [[OBUser alloc] init];
    user.login = login;
  }
  return user;
}

+ (NSData *) defaultAvatarData {
  if (!defaultAvatarData) {
    NSString *imagePath = [[NSBundle mainBundle] pathForImageResource: @"ob_default_avatar.png"];
    defaultAvatarData = [NSData dataWithContentsOfFile: imagePath];
  }
  return defaultAvatarData;
}

- (id) init {
  return [super initWithProperties: OBArray(@"login")];
}

- (void) setLogin: (NSString *) newLogin {
  if (login) {
    [loginIndex removeObjectForKey: login];
  }
  [login release];
  login = [newLogin copy];
  [loginIndex setObject: self forKey: login];
}

- (void) setAvatarData: (NSData *) data {
  [avatarData release];
  [avatar release];
  avatarData = [data copy];
  avatar = [[OBImage alloc] initWithData: data];
}

- (BOOL) isEqual: (id) other {
  if ([other isKindOfClass: [OBUser class]]) {
    return [[other login] isEqual: login];
  } else {
    return false;
  }
}

- (NSUInteger) hash {
  return [login hash];
}

@end
