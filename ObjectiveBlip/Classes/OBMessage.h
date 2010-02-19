// -------------------------------------------------------
// OBMessage.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>
#import "OBModel.h"

@interface OBMessage : OBModel {
  NSString *body;
  NSString *username;
  NSDate *date;

  NSString *userPath;
  NSString *createdAt;
}

@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *userPath;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, copy) NSString *createdAt;

@end
