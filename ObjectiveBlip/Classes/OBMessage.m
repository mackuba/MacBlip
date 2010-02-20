// -------------------------------------------------------
// OBMessage.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "OBMessage.h"
#import "OBUser.h"
#import "OBUtils.h"

@implementation OBMessage

@synthesize userPath, body, date, user, createdAt;
OnDeallocRelease(userPath, body, date, user, createdAt);

- (id) init {
  return [super initWithProperties: OBArray(@"body", @"userPath", @"createdAt")];
}

- (void) setUserPath: (NSString *) path {
  [userPath release];
  [user release];
  userPath = [path copy];
  NSString *login = [[path componentsSeparatedByString: @"/"] lastObject];
  user = [[OBUser findOrCreateByLogin: login] retain];
}

+ (NSDateFormatter *) timeZoneLessDateFormatter {
  static NSDateFormatter *formatter = nil;
  if (!formatter) {
    formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName: @"Europe/Warsaw"];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
  }
  return formatter;
}

- (void) setCreatedAt: (NSString *) created {
  [createdAt release];
  [date release];
  createdAt = [created copy];
  date = [[[[self class] timeZoneLessDateFormatter] dateFromString: createdAt] retain];
}

- (NSString *) description {
  return OBFormat(@"<OBMessage: user.login=%@, date=%@, body=\"%@\">", user.login, date, body);
}

@end
