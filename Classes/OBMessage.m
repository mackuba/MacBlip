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

@synthesize username, userPath, body;
OnDeallocRelease(username, userPath, body);

- (id) init {
  return [super initWithProperties: OBArray(@"body", @"username", @"userPath")];
}

- (void) setUserPath: (NSString *) path {
  [userPath release];
  [username release];
  userPath = [path copy];
  username = [[[path componentsSeparatedByString: @"/"] lastObject] copy];
}

@end
