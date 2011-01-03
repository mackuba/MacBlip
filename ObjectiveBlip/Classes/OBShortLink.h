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
#import "OBUtils.h"

@interface OBShortLink : PSModel {
  NSString *url;
  NSString *originalLink;
  NSString *shortcode;
}

@property (nonatomic, copy) NSString *originalLink;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *shortcode;

+ (OBShortLink *) shortLinkWithRdirUrl: (NSString *) url;
+ (OBShortLink *) shortLinkWithOriginalLink: (NSString *) url;

@end
