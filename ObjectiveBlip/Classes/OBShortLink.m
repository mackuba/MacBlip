// -------------------------------------------------------
// OBShortLink.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "OBShortLink.h"

@implementation OBShortLink

@synthesize url, originalLink, shortcode;
PSReleaseOnDealloc(url, originalLink, shortcode);

+ (NSArray *) propertyList {
  return PSArray(@"url", @"originalLink", @"shortcode");
}

+ (NSString *) routeName {
  return @"shortlinks";
}

+ (OBShortLink *) shortLinkWithRdirUrl: (NSString *) url {
  if ([url hasPrefix: @"http://rdir.pl/"]) {
    NSString *code = [[url componentsSeparatedByString: @"/"] objectAtIndex: 3];
    if (code.length > 0) {
      OBShortLink *shortLink = [[OBShortLink alloc] init];
      shortLink.shortcode = code;
      shortLink.url = url;
      return [shortLink autorelease];
    }
  }
  return nil;
}

+ (OBShortLink *) shortLinkWithOriginalLink: (NSString *) url {
  OBShortLink *shortLink = [[OBShortLink alloc] init];
  shortLink.originalLink = url;
  return [shortLink autorelease];
}

- (NSString *) url {
  if (!url && shortcode) {
    self.url = PSFormat(@"http://rdir.pl/%@", shortcode);
  }
  return url;
}

- (NSString *) toParam {
  return shortcode;
}

- (NSString *) encodeToPostData {
  return PSFormat(@"shortlink[original_link]=%@", [originalLink psStringWithPercentEscapesForFormValues]);
}

@end
