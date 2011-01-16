// -------------------------------------------------------
// MessagePictureView.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
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
