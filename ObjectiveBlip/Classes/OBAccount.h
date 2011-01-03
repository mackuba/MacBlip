// -------------------------------------------------------
// OBAccount.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

/*
  OBAccount - represents current user's account
*/

#import <Foundation/Foundation.h>
#import "OBUtils.h"

@interface OBAccount : PSAccount {
  BOOL loggedIn;
}

@property (nonatomic, getter=isLoggedIn) BOOL loggedIn;

- (BOOL) hasCredentials;

@end
