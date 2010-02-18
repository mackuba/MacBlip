//
//  SDKeychain.h
//

#import <Cocoa/Cocoa.h>

#import <Security/Security.h>

@interface SDKeychain : NSObject {
}

+ (NSString*) securePasswordForIdentifier:(NSString*)username;
+ (BOOL) setSecurePassword:(NSString*)somePassword forIdentifier:(NSString*)username;

@end
