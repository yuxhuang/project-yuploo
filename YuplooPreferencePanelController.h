//
//  YuplooPreferencePanelController.h
//  Yuploo
//
//  Created by Felix Huang on 11/05/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class YuplooMainWindowController;

@interface YuplooPreferencePanelController : NSWindowController {
	YuplooMainWindowController *mainWindowController;
}

@property(readonly) YuplooMainWindowController *mainWindowController;

@end
