// -------------------------------------------------------
// OBAccount.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "OBAccount.h"

@implementation OBAccount

@synthesize loggedIn;

- (id) init {
  self = [super init];
  if (self) {
    loggedIn = NO;
  }
  return self;
}

- (BOOL) hasCredentials {
  return [self hasAllRequiredProperties];
}

@end
