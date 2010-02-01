// -------------------------------------------------------
// OBUtils.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "OBUtils.h"

@implementation NSString (OBUtils)

- (NSString *) trimmedString {
  NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  return [self stringByTrimmingCharactersInSet: whitespace];
}

- (NSString *) camelizedString {
  NSArray *words = [self componentsSeparatedByString: @"_"];
  if (words.count == 1) {
    return [[self copy] autorelease];
  } else {
    NSMutableString *camelized = [[NSMutableString alloc] initWithString: [words objectAtIndex: 0]];
    for (NSInteger i = 1; i < words.count; i++) {
      [camelized appendString: [[words objectAtIndex: i] capitalizedString]];
    }
    return [camelized autorelease];
  }
}

@end
