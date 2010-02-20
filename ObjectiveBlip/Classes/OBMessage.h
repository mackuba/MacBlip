// -------------------------------------------------------
// OBMessage.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>
#import "OBModel.h"

@class OBUser;

@interface OBMessage : OBModel {
  // interesting stuff
  NSString *body;
  NSDate *date;
  OBUser *user;

  // less interesting stuff
  NSString *userPath;
  NSString *createdAt;
}

@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *userPath;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, retain) OBUser *user;

@end
