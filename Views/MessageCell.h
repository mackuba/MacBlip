// -------------------------------------------------------
// MessageCell.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under GPL v3 license
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>

@interface MessageCell : NSView {
  NSSize padding;
  NSPoint textViewOrigin;
  NSTextView *textView;
  NSTextField *userLabel;
  NSTextField *dateLabel;
  NSColorWell *colorWell;  // hidden control which is only used to store the appropriate background color
  NSImageView *pictureView;
  NSFont *userLabelFont;
}

@property (readonly) NSSize padding;
@property IBOutlet NSTextView *textView;
@property IBOutlet NSTextField *userLabel;
@property IBOutlet NSTextField *dateLabel;
@property IBOutlet NSColorWell *colorWell;
@property IBOutlet NSImageView *pictureView;

+ (NSColor *) backgroundColor;
- (void) initializeLayoutWithTextFrame: (NSRect) scrollViewFrame withPicture: (BOOL) hasPicture;
- (NSColor *) messageBackgroundColor;

@end
