// -------------------------------------------------------
// MessageCell.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under Eclipse Public License v1.0
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>

@interface MessageCell : NSView {
  NSPoint textViewOrigin;
  NSFont *userLabelFont;
}

@property (readonly) NSSize padding;
@property IBOutlet NSTextView *textView;
@property IBOutlet NSTextField *userLabel;
@property IBOutlet NSTextField *dateLabel;
@property IBOutlet NSColorWell *colorWell; // hidden control which is only used to store the appropriate background color
@property IBOutlet NSImageView *pictureView;

+ (NSColor *) backgroundColor;
- (void) initializeLayoutWithTextFrame: (NSRect) scrollViewFrame withPicture: (BOOL) hasPicture;
- (NSColor *) messageBackgroundColor;

@end
