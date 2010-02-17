/*
 *  SDListViewItem+Private.h
 *  SingleListExample
 *
 *  Created by Steven Degutis on 10/27/09.
 *
 */

// dont use this stuff... im total serious. dont.

#import "SDListViewItem.h"

@interface SDListViewItem (SDPrivate)

- (void) setListView:(SDListView*)someListView;
- (void) setSelected:(BOOL)isSelected;

@end
