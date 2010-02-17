//
//  SDListViewItem.h
//  SingleListExample
//
//  Created by Steven Degutis on 10/26/09.
//

#import <Cocoa/Cocoa.h>

@class SDListView;

@interface SDListViewItem : NSViewController <NSCopying> {
	SDListView *listView;
	BOOL selected;
}

@property (readwrite, retain) id representedObject;
@property (readwrite, retain) NSView *view;

@property (readonly, assign) SDListView *listView;

@property (readonly, getter=isSelected) BOOL selected;

// to be overridden by subclasses
- (CGFloat) heightForGivenWidth:(CGFloat)width;

// can be used by subclasses to note the height has been changed
- (void) noteViewHeightChanged;

@end
