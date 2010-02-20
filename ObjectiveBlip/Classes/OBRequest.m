// -------------------------------------------------------
// OBRequest.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Constants.h"
#import "OBRequest.h"

@implementation OBRequest

@synthesize target;

- (id) initWithPath: (NSString *) path
             method: (NSString *) method
               text: (NSString *) text {
  NSURL *wrappedUrl = [NSURL URLWithString: [BLIP_API_HOST stringByAppendingString: path]];
  self = [super initWithURL: wrappedUrl];
  if (self) {
    self.timeOutSeconds = 15;
    self.shouldRedirect = NO;
    self.requestMethod = method;
    [self addRequestHeader: @"X-Blip-API" value: BLIP_API_VERSION];
    [self addRequestHeader: @"Accept" value: @"application/json"];
    [self addRequestHeader: @"Content-Type" value: @"application/json"];
    if (text) {
      [self appendPostData: [text dataUsingEncoding: NSUTF8StringEncoding]];
    }
  }
  return self;
}

- (void) sendFor: (id) tgt {
  target = tgt;
  [self startAsynchronous];
}

- (void) send {
  [self startAsynchronous];
}

@end
