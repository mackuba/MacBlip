// -------------------------------------------------------
// AvatarView.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import "AvatarView.h"
#import "MessageCell.h"

@implementation AvatarView

- (void) drawRect: (NSRect) rect {
  NSRect wholeImage = self.bounds;
  [super drawRect: wholeImage];

  id superview = [self superview];
  NSColor *background = [superview messageBackgroundColor];
  [background set];

  NSRect borderRect = NSInsetRect(wholeImage, -2.0, -2.0);
  NSBezierPath *rounded = [NSBezierPath bezierPathWithRoundedRect: borderRect xRadius: 7.0 yRadius: 7.0];
  [rounded setLineWidth: 5.0];
  [rounded stroke];
}

- (void) mouseDown: (NSEvent *) event {
  if (self.target) {
    [NSApp sendAction: self.action to: self.target from: self];
  }
}

@end
