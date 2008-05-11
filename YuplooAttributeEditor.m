//
//  YuplooAttributeEditor.m
//  Yuploo
//
//  Created by Felix Huang on 25/04/08.
//  Copyright 2008 Two Fathoms Deep. All rights reserved.
//

#import "YuplooAttributeEditor.h"
#import "YuplooMainWindowController.h"
#import "PhotoItem.h"

@implementation YuplooAttributeEditor

@synthesize mainWindowController;

- (id)initWithMainWindowController:(YuplooMainWindowController *)aController
{
	self = [super initWithNibName:@"AttributeEditor" bundle:nil];
	
	if (nil != self) {
		mainWindowController = [aController retain];
		drawer = [[NSDrawer alloc] initWithContentSize:NSMakeSize(307, 308) preferredEdge:NSMaxXEdge];
	}
	return self;
}

- (void)dealloc
{
	[drawer release];
	[mainWindowController release];
	[super dealloc];
}

- (void)loadView
{	
	[super loadView];
	[drawer setParentWindow:mainWindowController.window];

	NSSize size = [self.view bounds].size;
	[drawer setPreferredEdge:NSMaxXEdge];
	[drawer setContentView:self.view];
	[drawer setContentSize:size];
	[drawer setMinContentSize:size];
	[drawer setMaxContentSize:[self.view bounds].size];
}

#pragma mark Photo Editing
- (void)startEditing
{
	[drawer open];
}



- (void)endEditing
{
	[drawer close];
}
@end
