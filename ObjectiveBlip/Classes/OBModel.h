// -------------------------------------------------------
// OBModel.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

/*
  OBModel - base class for Blip models (OBMessage, OBUser, etc.)
*/

#import <Foundation/Foundation.h>

#define RECORD_ID @"recordId"

@interface OBModel : NSObject <NSCopying> {
  NSInteger recordId;
  NSArray *properties;
}

@property (nonatomic) NSInteger recordId;
@property (nonatomic, readonly) NSArray *properties;

+ (id) objectFromJSON: (NSDictionary *) json;
+ (id) objectFromJSONString: (NSString *) jsonString;
+ (NSArray *) objectsFromJSONString: (NSString *) jsonString;

+ (void) appendObjectsToList: (NSArray *) objects;
+ (void) addObjectsToBeginningOfList: (NSArray *) objects;
+ (id) objectWithId: (NSInteger) objectId;
+ (NSInteger) count;
+ (NSMutableArray *) list;
+ (NSMutableDictionary *) identityMap;
+ (void) reset;

- (id) initWithProperties: (NSArray *) propertyList;
- (BOOL) isEqual: (id) other;

@end
