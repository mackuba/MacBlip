// -------------------------------------------------------
// ModelManager.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "OBModelManager.h"

@implementation OBModelManager

@synthesize list, identityMap;

- (id) init {
  self = [super init];
  if (self) {
    list = [[NSMutableArray alloc] initWithCapacity: 100];
    identityMap = [[NSMutableDictionary alloc] initWithCapacity: 100];
  }
  return self;
}

+ (OBModelManager *) managerForClass: (NSString *) className {
  static NSMutableDictionary *managers;
  if (!managers) {
    managers = [[NSMutableDictionary alloc] initWithCapacity: 5];
  }
  OBModelManager *manager = [managers objectForKey: className];
  if (!manager) {
    manager = [[OBModelManager alloc] init];
    [managers setObject: manager forKey: className];
    [manager release];
  }
  return manager;
}

@end
