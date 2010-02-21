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

@synthesize userPath, recipientPath, body, date, user, recipient, createdAt, messageType, type;
OnDeallocRelease(userPath, recipientPath, body, date, user, recipient, createdAt, type);

- (id) init {
  return [super initWithProperties: OBArray(@"body", @"userPath", @"createdAt", @"recipientPath", @"type")];
}

- (void) setUserPath: (NSString *) path {
  [userPath release];
  [user release];
  userPath = [path copy];
  NSString *login = [[path componentsSeparatedByString: @"/"] lastObject];
  user = [[OBUser findOrCreateByLogin: login] retain];
}

- (void) setRecipientPath: (NSString *) path {
  [recipientPath release];
  [recipient release];
  recipientPath = [path copy];
  NSString *login = [[path componentsSeparatedByString: @"/"] lastObject];
  recipient = [[OBUser findOrCreateByLogin: login] retain];
}

- (void) setType: (NSString *) typeName {
  [type release];
  type = [typeName copy];
  if ([type isEqual: @"PrivateMessage"]) {
    messageType = OBPrivateMessage;
  } else if ([type isEqual: @"DirectedMessage"]) {
    messageType = OBDirectedMessage;
  } else {
    messageType = OBStatusMessage;
  }
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
