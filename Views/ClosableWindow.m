// -------------------------------------------------------
// ClosableWindow.m
//
// Copyright (c) 2011 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import "ClosableWindow.h"

@implementation ClosableWindow

- (void) sendEvent: (NSEvent *) event {
  // close window when user presses ESC
  if (event.type == NSKeyDown && event.keyCode == 53) {
    [self performClose: self];
  } else {
    [super sendEvent: event];
  }
}

@end
