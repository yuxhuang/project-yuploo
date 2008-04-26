//
//  YuplooAttributeEditor.h
//  Yuploo
//
//  Created by Felix Huang on 25/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class YuplooMainWindowController;

@interface YuplooAttributeEditor : NSObject {
	YuplooMainWindowController *mainWindowController;
}

@property(readonly) YuplooMainWindowController *mainWindowController;

- (id)initWithMainWindowController:(YuplooMainWindowController *)aController;

- (void)loadNib;
@end
