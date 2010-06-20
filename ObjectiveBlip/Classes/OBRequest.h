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

typedef enum { OBJSONRequest, OBImageRequest, OBHTMLRequest } OBRequestContentType;

@interface OBRequest : ASIHTTPRequest {
  id target;
  OBRequestContentType requestContentType;
}

@property (nonatomic, readonly) id target;
@property (nonatomic, assign) OBRequestContentType requestContentType;

- (id) initWithPath: (NSString *) path
             method: (NSString *) method
               text: (NSString *) text;

- (void) sendFor: (id) target;
- (void) send;

@end
