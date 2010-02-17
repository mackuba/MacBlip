//
//  SDKVO.m
//  SingleListExample
//
//  Created by Steven Degutis on 10/26/09.
//

#import "SDKVO.h"

@interface SDKVO : NSObject {
	id observee;
	NSString *keyPath;
	void (^handler)(id object, NSDictionary *change, id self);
}

@property (readwrite, assign) id observee;
@property (readwrite, copy) NSString *keyPath;
@property (readwrite, copy) void (^handler)(id object, NSDictionary *change, id nonretainedSelf);

@end


@implementation SDKVO

@synthesize observee;
@synthesize keyPath;
@synthesize handler;

- (void) dealloc {
	[self.observee removeObserver:self forKeyPath:self.keyPath];
	[super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)someKeyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	if (self.handler)
		self.handler(object, change, context);
}

@end

@implementation NSObject (SDKVO)

- (id) observeKeyPath:(NSString*)newKeyPath
			  options:(NSKeyValueObservingOptions)someOptions
			 weakSelf:(id)weakSelf
			  handler:(void(^)(id object, NSDictionary *change, id nonretainedSelf))newHandler
{
	SDKVO *observer = [[[SDKVO alloc] init] autorelease];
	
	observer.observee = self;
	observer.keyPath = newKeyPath;
	observer.handler = newHandler;
	
	[observer.observee addObserver:observer
						forKeyPath:observer.keyPath
						   options:someOptions
						   context:weakSelf];
	
	return observer;
}

@end
