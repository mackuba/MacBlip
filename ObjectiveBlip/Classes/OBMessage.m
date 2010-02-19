// -------------------------------------------------------
// OBMessage.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "NSArray+BSJSONAdditions.h"
#import "OBMessage.h"
#import "OBUtils.h"

@implementation OBMessage

@synthesize username, userPath, body, date, createdAt;
OnDeallocRelease(username, userPath, body, date, createdAt);

- (id) init {
  return [super initWithProperties: OBArray(@"body", @"username", @"userPath", @"date", @"createdAt")];
}

- (void) setUserPath: (NSString *) path {
  [userPath release];
  [username release];
  userPath = [path copy];
  username = [[[path componentsSeparatedByString: @"/"] lastObject] copy];
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
  return OBFormat(@"<OBMessage: username=%@, date=%@, body=\"%@\">", username, date, body);
}

@end
