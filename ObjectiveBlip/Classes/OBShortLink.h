// -------------------------------------------------------
// OBShortLink.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

/*
  OBShortLink - shortened URL (rdir.pl)
*/

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "PSModel.h"

@interface OBShortLink : PSModel {
  NSString *url;
  NSString *originalLink;
}

@property (nonatomic, copy) NSString *originalLink;
@property (nonatomic, copy) NSString *url;

@end
