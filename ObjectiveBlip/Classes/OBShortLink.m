// -------------------------------------------------------
// OBShortLink.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "OBShortLink.h"
#import "PsiToolkit.h"

@implementation OBShortLink

@synthesize url, originalLink;
PSReleaseOnDealloc(url, originalLink);

+ (NSArray *) propertyList {
  return PSArray(@"url", @"originalLink");
}

@end
