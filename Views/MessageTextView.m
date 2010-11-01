// -------------------------------------------------------
// MessageTextView.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under GPL v3 license
// -------------------------------------------------------

#import "MessageTextView.h"
#import "PsiToolkit.h"

@implementation MessageTextView

- (void) awakeFromNib {
  NSCursor *hand = [NSCursor pointingHandCursor];
  NSColor *blue = [NSColor colorWithDeviceRed: 0.2 green: 0.4 blue: 0.8 alpha: 1.0];
  
  NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
  [attributes setObject: PSInt(NSUnderlineStyleNone) forKey: NSUnderlineStyleAttributeName];
  [attributes setObject: hand forKey: NSCursorAttributeName];
  [attributes setObject: blue forKey: NSForegroundColorAttributeName];
  self.linkTextAttributes = attributes;
}

- (NSMenu *) menuForEvent: (NSEvent *) event {
  // menu returned by parent class is a custom menu built by NSTextView, with service items merged in
  // self.menu is our base menu, assigned by the controller
  // here, we make sure that the new menu has the same delegate reference (it's needed later in the handler)
  NSMenu *menu = [super menuForEvent: event];
  menu.delegate = self.menu.delegate;
  return menu;
}

- (BOOL) acceptsFirstResponder {
  // unselect currently selected text in another text view, if any
  id previous = self.window.firstResponder;
  if ([previous isKindOfClass: [MessageTextView class]]) {
    [previous setSelectedRange: NSMakeRange(0, 0)];
  }
  return YES;
}

// don't draw vertical text cursor
- (BOOL) shouldDrawInsertionPoint {
  return NO;
}

// disables annoying "Get Current Selection (Internal)" service menu item from Quicksilver
- (id) validRequestorForSendType: (NSString *) sendType returnType: (NSString *) returnType {
  return nil;
}

@end
