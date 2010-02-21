// -------------------------------------------------------
// OBUser.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#if TARGET_OS_IPHONE
  #import <UIKit/UIKit.h>
  #define OBImage UIImage
#else
  #import <Cocoa/Cocoa.h>
  #define OBImage NSImage
#endif

#import "OBModel.h"


@interface OBUser : OBModel {
  NSString *login;
  OBImage *avatar;
  NSData *avatarData;
}

@property (nonatomic, copy) NSString *login;
@property (nonatomic, readonly) OBImage *avatar;
@property (nonatomic, copy) NSData *avatarData;

+ (OBUser *) findOrCreateByLogin: (NSString *) login;
+ (NSData *) defaultAvatarData;

@end
