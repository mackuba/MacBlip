//
//  SDListView.h
//  SingleListExample
//
//  Created by Steven Degutis on 10/26/09.
//

/* Notes:
 * (1) I am starting to love this new style of commenting
 * (2) "Multiple Selection" is not yet implemented
 */

#import <Cocoa/Cocoa.h>

@class SDListViewItem;

@interface SDListView : NSView {
	NSArray *content;
	SDListViewItem *prototypeItem;
	NSArray *sortDescriptors;
	
	NSMutableArray *observers;
	
	NSMutableArray *listViewItems;
	NSMutableArray *viewsThatShouldNotAnimate;
	
	CGFloat topPadding;
	CGFloat bottomPadding;
	
	BOOL selectable;
	BOOL allowsMultipleSelection;
	
	NSUInteger initialDraggingIndex;
	
	int selectionFellOfSide;
}

@property (readwrite, copy) NSArray *sortDescriptors;

@property (readwrite, copy) NSArray *content;
@property (readwrite, retain) IBOutlet SDListViewItem *prototypeItem;

@property (readwrite) CGFloat topPadding;
@property (readwrite) CGFloat bottomPadding;

@property (readwrite, getter=isSelectable, setter=setSelectable:) BOOL selectable;
@property (readwrite) BOOL allowsMultipleSelection;

@property (readwrite, retain) NSIndexSet *selectionIndexes;

// default impl. just copies self.prototypeItem and sets its repObject
- (SDListViewItem*) newItemForRepresentedObject:(id)object;

- (NSUInteger) indexOfItem:(SDListViewItem*)item;
- (SDListViewItem*) itemAtIndex:(NSUInteger)index;
- (NSRect) frameForItemAtIndex:(NSUInteger)index;

@end
