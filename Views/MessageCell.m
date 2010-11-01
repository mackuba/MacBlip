// -------------------------------------------------------
// MessageCell.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under GPL v3 license
// -------------------------------------------------------

#import "MessageCell.h"
#import "PsiToolkit.h"

static NSColor *borderColor;
static NSColor *backgroundColor;
static NSInteger labelPadding = 4;

@implementation MessageCell

@synthesize padding, textView, userLabel, dateLabel, colorWell, pictureView;

+ (void) initialize {
  borderColor = [NSColor colorWithDeviceWhite: 0.6 alpha: 1.0];
  backgroundColor = [NSColor colorWithDeviceWhite: 0.94 alpha: 1.0];
}

+ (NSColor *) backgroundColor {
  return backgroundColor;
}

- (void) awakeFromNib {
  userLabelFont = userLabel.font;
}

- (void) initializeLayoutWithTextFrame: (NSRect) scrollViewFrame withPicture: (BOOL) hasPicture {
  textViewOrigin = scrollViewFrame.origin;
  CGFloat verticalPadding = self.frame.size.height - scrollViewFrame.size.height;
  CGFloat horizontalPadding = self.frame.size.width - scrollViewFrame.size.width;
  if (hasPicture) {
    horizontalPadding += pictureView.frame.size.width;
  }
  padding = NSMakeSize(horizontalPadding, verticalPadding);
}

- (NSColor *) messageBackgroundColor {
  return colorWell.color;
}

- (void) drawRect: (NSRect) rect {
  NSRect wholeCell = self.bounds;
  NSRect padded = NSInsetRect(wholeCell, 10.0, 5.0);
  NSBezierPath *rounded = [NSBezierPath bezierPathWithRoundedRect: padded xRadius: 5.0 yRadius: 5.0];

  [[self messageBackgroundColor] set];
  [rounded fill];

  [borderColor set];
  [rounded stroke];

  [super drawRect: padded];
}

- (void) resizeSubviewsWithOldSize: (NSSize) oldSize {
  NSString *user = userLabel.stringValue;
  NSString *date = dateLabel.stringValue;
  CGFloat oldDateWidth = dateLabel.frame.size.width;
  NSSize newDateSize = [date sizeWithAttributes: PSDict(dateLabel.font, NSFontAttributeName)];
  CGFloat newDateWidth = newDateSize.width + labelPadding;
  CGFloat space = dateLabel.frame.origin.x + oldDateWidth - userLabel.frame.origin.x;
  NSRect frame;

  frame = dateLabel.frame;
  frame.size.width = newDateWidth;
  frame.origin.x += oldDateWidth - newDateWidth;
  dateLabel.frame = frame;

  userLabel.font = userLabelFont;
  NSSize newUserSize = [user sizeWithAttributes: PSDict(userLabelFont, NSFontAttributeName)];
  CGFloat newUserWidth = newUserSize.width + labelPadding;

  while (space - newDateWidth < newUserWidth) {
    userLabel.font = [NSFont fontWithName: userLabel.font.fontName size: userLabel.font.pointSize - 0.5];
    NSSize size = [user sizeWithAttributes: PSDict(userLabel.font, NSFontAttributeName)];
    newUserWidth = size.width + labelPadding;
  }

  frame = userLabel.frame;
  frame.size.width = space - newDateWidth;
  userLabel.frame = frame;

  frame = textView.frame;
  frame.origin = textViewOrigin;
  frame.size.width = self.frame.size.width - padding.width;
  frame.size.height = self.frame.size.height - padding.height;
  textView.frame = frame;

  [super resizeSubviewsWithOldSize: oldSize];
}

@end
