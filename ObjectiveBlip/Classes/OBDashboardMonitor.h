// -------------------------------------------------------
// OBDashboardMonitor.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

/*
  OBDashboardMonitor - keeps a timer which activates it in specified intervals, and sends requests to update the
  dashboard when it does
*/

#import <Foundation/Foundation.h>

#define OBDashboardUpdatedNotification @"OBDashboardUpdatedNotification"
#define OBDashboardWillUpdateNotification @"OBDashboardWillUpdateNotification"
#define OBDashboardUpdateFailedNotification @"OBDashboardUpdateFailedNotification"
#define OBDashboardAuthFailedNotification @"OBDashboardAuthFailedNotification"

@class OBConnector;

@interface OBDashboardMonitor : NSObject {
  NSTimer *monitorTimer;
  __weak OBConnector *connector;
  BOOL isSendingDashboardRequest;
  NSInteger interval;
}

@property (nonatomic, assign) NSInteger interval;

- (id) initWithConnector: (OBConnector *) obConnector;
- (void) startMonitoring;
- (void) stopMonitoring;

// will make an update now no matter what
- (void) forceUpdate;

// will try to make an update outside of normal schedule, unless there's one in progress
- (void) requestManualUpdate;

@end
