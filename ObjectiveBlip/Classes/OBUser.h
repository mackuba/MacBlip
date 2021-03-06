// -------------------------------------------------------
// OBUser.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

/*
  OBUser - represents a Blip user
*/

#import "OBUtils.h"

@interface OBUser : PSModel {
  NSString *login;
  NSData *avatarData;
}

@property (nonatomic, copy) NSString *login;
@property (nonatomic, copy) NSData *avatarData;

+ (OBUser *) findOrCreateByLogin: (NSString *) login;

@end
