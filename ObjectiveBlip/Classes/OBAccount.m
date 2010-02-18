// -------------------------------------------------------
// OBAccount.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "OBAccount.h"

@implementation OBAccount

@synthesize username, loggedIn, password;

- (id) init {
  self = [super init];
  if (self) {
    loggedIn = NO;
  }
  return self;
}

- (BOOL) hasCredentials {
  return username && password && (username.length > 0) && (password.length > 0);
}

@end
