//
//  YuplooAttributeEditor.h
//  Yuploo
//
//  Created by Felix Huang on 25/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class YuplooMainWindowController;
@class PhotoItem;

@interface YuplooAttributeEditor : NSViewController {
	YuplooMainWindowController *mainWindowController;
	NSDrawer *drawer;
	PhotoItem *selectedPhoto;
}

@property(readonly) YuplooMainWindowController *mainWindowController;

// initialization
- (id)initWithMainWindowController:(YuplooMainWindowController *)aController;

// photo editing
- (void)editPhoto:(PhotoItem *)photo;
- (void)endEditing;

@end
