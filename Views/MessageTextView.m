// -------------------------------------------------------
// MessageTextView.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under GPL v3 license
// -------------------------------------------------------

#import "MessageTextView.h"

@implementation MessageTextView

- (void) awakeFromNib {
  NSCursor *hand = [NSCursor pointingHandCursor];
  NSColor *blue = [NSColor colorWithDeviceRed: 0.2 green: 0.4 blue: 0.8 alpha: 1.0];
  
  NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
  [attributes setObject: PSInt(NSUnderlineStyleNone) forKey: NSUnderlineStyleAttributeName];
  [attributes setObject: hand forKey: NSCursorAttributeName];
  [attributes setObject: blue forKey: NSForegroundColorAttributeName];
  self.linkTextAttributes = attributes;
  self.displaysLinkToolTips = false;
}

- (void) resizeWithOldSuperviewSize: (NSSize) size {
  [super resizeWithOldSuperviewSize: size];
  [self refreshToolTips];
}

- (void) observeValueForKeyPath: (NSString *) path
                       ofObject: (id) source
                         change: (NSDictionary *) change
                        context: (void *) context {
  // due to the way events are processed, when this is called at the moment when processedBody changes,
  // the text view hasn't been through the binding yet, so we refresh tooltips after event loop finishes
  [self performSelector: @selector(refreshToolTips) withObject: nil afterDelay: 0.1];
}

- (void) refreshToolTips {
  [self removeAllToolTips];

  // ugly hack to make the tooltip delay smaller than default (3-4s)
  // to do that, we need to add tooltips to the text view manually and set the delay in private class NSTooltipManager

  NSInteger position = 0;
  NSRange range;
  NSRange empty = { NSNotFound, 0 };
  NSAttributedString *string = self.textStorage;
  NSLayoutManager *layout = self.layoutManager;
  NSTextContainer *container = self.textContainer;
  NSRectArray rectArray;
  NSUInteger rectCount;
  NSUInteger r;

  while (position < string.length) {
    NSURL *link = [string attribute: NSLinkAttributeName atIndex: position effectiveRange: &range];
    if (link) {
      rectArray = [layout rectArrayForCharacterRange: range
                        withinSelectedCharacterRange: empty
                                     inTextContainer: container
                                           rectCount: &rectCount];
      for (r = 0; r < rectCount; r++) {
        [self addToolTipRect: rectArray[r] owner: link userData: nil];
      }
    }
    position += range.length;
  }
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
