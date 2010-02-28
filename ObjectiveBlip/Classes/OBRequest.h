// -------------------------------------------------------
// OBRequest.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

/*
  OBRequest - represents a single request to Blip API
*/

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@interface OBRequest : ASIHTTPRequest {
  id target;
}

@property (nonatomic, readonly) id target;

- (id) initWithPath: (NSString *) path
             method: (NSString *) method
               text: (NSString *) text;

- (void) sendFor: (id) target;
- (void) send;

@end
