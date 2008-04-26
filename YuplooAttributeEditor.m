//
//  YuplooAttributeEditor.m
//  Yuploo
//
//  Created by Felix Huang on 25/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
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
	[drawer dealloc];
	[mainWindowController release];
	[super dealloc];
}

- (void)loadView
{	
	[super loadView];
	[drawer setParentWindow:mainWindowController.window];

	NSSize size = [self.view bounds].size;
	[drawer setContentView:self.view];
	[drawer setContentSize:size];
	[drawer setMinContentSize:size];
	[drawer setMaxContentSize:[self.view bounds].size];
	[self.view setFrame:NSMakeRect(0, 150, size.width, size.height)];
	NSLog(@"%d %d %d", [drawer contentView], [drawer contentSize].width, [drawer contentSize].height);
}

#pragma mark Photo Editing
- (void)editPhoto:(PhotoItem *)aPhoto
{
	selectedPhoto = [aPhoto retain];
	[drawer open];
}

- (void)endEditing
{
	[selectedPhoto release];
	selectedPhoto = nil;
	[drawer close];
}
@end
