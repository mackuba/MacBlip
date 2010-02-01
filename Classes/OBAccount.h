// -------------------------------------------------------
// OBAccount.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@interface OBAccount : NSObject {
  BOOL loggedIn;
  NSString *username;
  NSString *password;
}

@property (nonatomic) BOOL loggedIn;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

@end
