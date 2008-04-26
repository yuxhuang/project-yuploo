//
//  YuplooAttributeEditor.m
//  Yuploo
//
//  Created by Felix Huang on 25/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "YuplooAttributeEditor.h"
#import "YuplooMainWindowController.h"


@implementation YuplooAttributeEditor

@synthesize mainWindowController;

- (id)initWithMainWindowController:(YuplooMainWindowController *)aController
{
	self = [super init];
	
	if (nil != self) {
		mainWindowController = [aController retain];
	}
	
	return self;
}

- (void)dealloc
{
	[mainWindowController release];
	[super dealloc];
}

- (void)loadNib
{
	[NSBundle loadNibNamed:@"AttributeEditor" owner:self];
}

@end
