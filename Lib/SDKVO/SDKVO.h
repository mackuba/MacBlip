//
//  SDKVO.h
//  SingleListExample
//
//  Created by Steven Degutis on 10/26/09.
//

#import <Cocoa/Cocoa.h>


@interface NSObject (SDKVO)

// <s>come with me</s> retain this, if you want (it) to live

- (id) observeKeyPath:(NSString*)newKeyPath
			  options:(NSKeyValueObservingOptions)someOptions
			 weakSelf:(id)nonretainedSelf
			  handler:(void(^)(id object, NSDictionary *change, id self))newHandler;

@end
