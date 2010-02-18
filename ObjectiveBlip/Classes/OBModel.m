// -------------------------------------------------------
// OBModel.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "OBModel.h"
#import "OBModelManager.h"
#import "OBUtils.h"
#import "NSArray+BSJSONAdditions.h"

@implementation OBModel

@synthesize recordId, properties;
OnDeallocRelease(properties);

// -------------------------------------------------------------------------------------------
#pragma mark Creating from JSON

+ (id) objectFromJSON: (NSDictionary *) json {
  // create a blank object
  OBModel *object = [[self alloc] init];
  NSArray *properties = [object properties];

  // set all properties
  for (NSString *key in [json allKeys]) {
    id value = nil;
    NSString *property;

    if ([key hasSuffix: @"_id"]) {
      // for names ending with _id, find an associated object in another Model
      property = [key substringToIndex: key.length - 3];
      id associationId = [json objectForKey: key];
      Class targetClass = NSClassFromString([@"OB" stringByAppendingString: [property capitalizedString]]);
      if (associationId != [NSNull null] && [targetClass respondsToSelector: @selector(objectWithId:)]) {
        value = [targetClass objectWithId: [associationId intValue]];
      }
    } else {
      // for other names, assign the value as is to a correct property
      value = [json objectForKey: key];

      if ([key isEqual: @"id"]) {
        // 'id' is saved as 'recordId'
        property = RECORD_ID;
      } else if ([key hasSuffix: @"?"]) {
        // 'foo?' is saved as 'foo'
        property = [[key substringToIndex: key.length - 1] camelizedString];
      } else {
        // normal property
        property = [key camelizedString];
      }
    }

    if (value != nil && [properties containsObject: property]) {
      [object setValue: value forKey: property];
    }
  }

  return [object autorelease];
}

+ (id) objectFromJSONString: (NSString *) jsonString {
  NSDictionary *record = [NSDictionary dictionaryWithJSONString: jsonString];
  return [self objectFromJSON: record];
}

+ (NSArray *) objectsFromJSONString: (NSString *) jsonString {
  NSArray *records = [NSArray arrayWithJSONString: jsonString];
  NSMutableArray *objects = [NSMutableArray arrayWithCapacity: records.count];
  for (NSDictionary *record in records) {
    [objects addObject: [self objectFromJSON: record]];
  }
  return objects;
}

// -------------------------------------------------------------------------------------------
#pragma mark Reading and updating global object list and map

+ (OBModelManager *) modelManager {
  return [OBModelManager managerForClass: NSStringFromClass([self class])];
}

+ (void) reset {
  [[self list] removeAllObjects];
  [[self identityMap] removeAllObjects];
}

+ (id) objectWithId: (NSInteger) objectId {
  return [[self identityMap] objectForKey: OBInt(objectId)];
}

+ (void) appendObjectsToList: (NSArray *) objects {
  NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0, objects.count)];
  [self willChange: NSKeyValueChangeInsertion valuesAtIndexes: indexes forKey: @"list"];
  [[self list] insertObjects: objects atIndexes: indexes];
  [self didChange: NSKeyValueChangeInsertion valuesAtIndexes: indexes forKey: @"list"];

  NSMutableDictionary *identityMap = [self identityMap];
  for (id object in objects) {
    [identityMap setObject: object forKey: [object valueForKey: RECORD_ID]];
  }
}

+ (NSInteger) count {
  return [[self list] count];
}

+ (NSMutableArray *) list {
  return [[self modelManager] list];
}

+ (NSMutableDictionary *) identityMap {
  return [[self modelManager] identityMap];
}

// -------------------------------------------------------------------------------------------
#pragma mark Instance methods

- (id) initWithProperties: (NSArray *) propertyList {
  self = [super init];
  if (self) {
    properties = [[propertyList arrayByAddingObject: RECORD_ID] retain];
  }
  return self;
}

- (id) copyWithZone: (NSZone *) zone {
  id other = [[[self class] alloc] init];
  for (NSString *property in properties) {
    id value = [self valueForKey: property];
    [other setValue: value forKey: property];
  }
  return other;
}

- (BOOL) isEqual: (id) other {
  if ([other isKindOfClass: [self class]]) {
    id otherRecordId = [other valueForKey: RECORD_ID];
    id myRecordId = [self valueForKey: RECORD_ID];
    return [otherRecordId isEqual: myRecordId];
  } else {
    return false;
  }
}

- (NSUInteger) hash {
  return recordId;
}

@end
