// -------------------------------------------------------
// OBUtils.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

#define ReleaseAll(...) \
  NSArray *_releaseList = [[NSArray alloc] initWithObjects: __VA_ARGS__, nil]; \
  for (NSObject *object in _releaseList) { \
    [object release]; \
  } \
  [_releaseList release];

#define OnDeallocRelease(...) \
  - (void) dealloc { \
    ReleaseAll(__VA_ARGS__); \
    [super dealloc]; \
  }

#define Observe(sender, notification, callback) \
  [[NSNotificationCenter defaultCenter] addObserver: self \
                                           selector: @selector(callback) \
                                               name: (notification) \
                                             object: (sender)]

#define StopObservingAll() [[NSNotificationCenter defaultCenter] removeObserver: self]
#define StopObserving(sender, notification) \
  [[NSNotificationCenter defaultCenter] removeObserver: self \
                                                  name: (notification) \
                                                object: (sender)]

#define NotifyWithData(notification, data) \
  [[NSNotificationCenter defaultCenter] postNotificationName: (notification) \
                                                      object: self \
                                                    userInfo: (data)]

#define Notify(notification) NotifyWithData((notification), nil)

#define OBArray(...) [NSArray arrayWithObjects: __VA_ARGS__, nil]
#define OBDict(...) [NSDictionary dictionaryWithObjectsAndKeys: __VA_ARGS__, nil]
#define OBFormat(...) [NSString stringWithFormat: __VA_ARGS__]
#define OBInt(i) [NSNumber numberWithInt: i]

@interface NSString (OBUtils)
- (NSString *) trimmedString;
- (NSString *) camelizedString;
@end
