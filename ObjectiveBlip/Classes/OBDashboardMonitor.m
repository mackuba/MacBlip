// -------------------------------------------------------
// OBDashboardMonitor.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "OBConnector.h"
#import "OBDashboardMonitor.h"
#import "OBUtils.h"

@interface OBDashboardMonitor ()
- (void) dashboardTimerFired: (NSTimer *) timer;
- (void) executeUpdate;
@end

@implementation OBDashboardMonitor

@synthesize interval;

- (id) initWithConnector: (OBConnector *) obConnector {
  self = [super init];
  if (self) {
    connector = obConnector;
    isSendingDashboardRequest = NO;
    interval = 10;
  }
  return self;
}

- (void) startMonitoring {
  [self stopMonitoring];
  monitorTimer = [NSTimer scheduledTimerWithTimeInterval: interval
                                                  target: self
                                                selector: @selector(dashboardTimerFired:)
                                                userInfo: nil
                                                 repeats: YES];
  [monitorTimer retain];
  [self executeUpdate];
}

- (void) stopMonitoring {
  [monitorTimer invalidate];
  monitorTimer = nil;
}

// will try to make an update outside of normal schedule, unless there's one in progress
- (void) requestManualUpdate {
  [self dashboardTimerFired: nil];
}

// will make an update now no matter what
- (void) forceUpdate {
  [self executeUpdate];
}

- (void) dashboardTimerFired: (NSTimer *) timer {
  if (!isSendingDashboardRequest) {
    [self executeUpdate];
  }
}

- (void) executeUpdate {
  isSendingDashboardRequest = YES;
  PSNotify(OBDashboardWillUpdateNotification);
  [[connector dashboardRequest] sendFor: self callback: @selector(dashboardUpdatedWithMessages:)];
}

- (void) dashboardUpdatedWithMessages: (NSArray *) messages {
  PSNotifyWithData(OBDashboardUpdatedNotification, PSHash(@"messages", messages));
  isSendingDashboardRequest = NO;
}

- (void) requestFailed: (PSRequest *) request withError: (NSError *) error {
  PSNotifyWithData(OBDashboardUpdateFailedNotification, PSHash(@"error", error));
  isSendingDashboardRequest = NO;
}

- (void) authenticationFailedInRequest: (PSRequest *) request {
  PSNotify(OBDashboardAuthFailedNotification);
  isSendingDashboardRequest = NO;
}

- (void) dealloc {
  [self stopMonitoring];
  [super dealloc];
}

@end
