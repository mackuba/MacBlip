// -------------------------------------------------------
// OBUser.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "OBUser.h"
#import "OBUtils.h"

static NSMutableDictionary *loginIndex;

@implementation OBUser

@synthesize login, avatar, avatarData;
OnDeallocRelease(login, avatar, avatarData);

+ (void) initialize {
  loginIndex = [[NSMutableDictionary alloc] initWithCapacity: 100];
}

+ (OBUser *) findOrCreateByLogin: (NSString *) login {
  OBUser *user = [loginIndex objectForKey: login];
  if (!user) {
    user = [[OBUser alloc] init];
    user.login = login;
  }
  return user;
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
