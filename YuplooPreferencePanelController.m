//
//  YuplooPreferencePanelController.m
//  Yuploo
//
//  Created by Felix Huang on 11/05/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "YuplooPreferencePanelController.h"
#import "YuplooMainWindowController.h"


@implementation YuplooPreferencePanelController

@synthesize mainWindowController;

- (id)initWithMainWindowController:(YuplooMainWindowController *)aController
{
	self = [super initWithWindowNibName:@"PrefsPanel"];
	
	if (nil != self) {
		mainWindowController = aController;
	}
	
	return self;
}

#pragma mark Window Delegate Methods

- (void)windowDidLoad
{
}
@end
