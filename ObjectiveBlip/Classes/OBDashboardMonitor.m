// -------------------------------------------------------
// OBDashboardMonitor.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "OBConnector.h"
#import "OBDashboardMonitor.h"
#import "OBRequest.h"
#import "OBUtils.h"

@interface OBDashboardMonitor ()
- (void) dashboardTimerFired: (NSTimer *) timer;
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
  [self forceUpdate];
}

- (void) stopMonitoring {
  [monitorTimer invalidate];
  monitorTimer = nil;
}

- (void) forceUpdate {
  [self dashboardTimerFired: nil];
}

- (void) dashboardTimerFired: (NSTimer *) timer {
  if (!isSendingDashboardRequest) {
    // TODO: if a request is waiting too long, kill it and try again
    isSendingDashboardRequest = YES;
    Notify(OBDashboardWillUpdateNotification);
    [[connector dashboardRequest] sendFor: self];
  }
}

- (void) dashboardUpdatedWithMessages: (NSArray *) messages {
  NotifyWithData(OBDashboardUpdatedNotification, OBDict(messages, @"messages"));
  isSendingDashboardRequest = NO;
}

- (void) requestFailedWithError: (NSError *) error {
  isSendingDashboardRequest = NO;
}

- (void) dealloc {
  [self stopMonitoring];
  [super dealloc];
}

@end
