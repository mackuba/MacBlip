// -------------------------------------------------------
// ModelManager.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

/*
  OBModelManager - helper class for OBModel, don't use it directly
*/

#import <Foundation/Foundation.h>

@interface OBModelManager : NSObject {
  NSMutableArray *list;
  NSMutableDictionary *identityMap;
}

@property (nonatomic, readonly) NSMutableArray *list;
@property (nonatomic, readonly) NSMutableDictionary *identityMap;

+ (OBModelManager *) managerForClass: (NSString *) className;

@end
