// -------------------------------------------------------
// MessagePictureView.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under GPL v3 license
// -------------------------------------------------------

#import "MessagePictureView.h"

@implementation MessagePictureView

- (void) mouseDown: (NSEvent *) event {
  if (self.target) {
    [NSApp sendAction: self.action to: self.target from: self];
  }
}

- (BOOL) acceptsFirstMouse: (NSEvent *) event {
  return YES;
}

@end
