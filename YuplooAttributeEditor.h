//
//  YuplooAttributeEditor.h
//  Yuploo
//
//  Created by Felix Huang on 25/04/08.
//  Copyright 2008 Two Fathoms Deep. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class YuplooMainWindowController;
@class PhotoItem;

@interface YuplooAttributeEditor : NSViewController {
	YuplooMainWindowController *mainWindowController;
	NSDrawer *drawer;
}

@property(readonly) YuplooMainWindowController *mainWindowController;

// initialization
- (id)initWithMainWindowController:(YuplooMainWindowController *)aController;

// photo editing
- (void)startEditing;
- (void)endEditing;

@end
