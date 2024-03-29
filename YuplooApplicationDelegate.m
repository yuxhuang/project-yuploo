//
//  YuplooApplicationDelegate.m
//  Yuploo
//
//  Created by Felix Huang on 21/02/08.
//  Copyright 2008 Two Fathoms Deep. All rights reserved.
//

#import "YuplooApplicationDelegate.h"
#import "YuplooController.h"
#import "YuplooMainWindowController.h"
#import "YuplooPreferencePanelController.h"

@implementation YuplooApplicationDelegate

@synthesize controller;

- (id)init
{
    self = [super init];
    
    if (nil != self) {
        // do some intialization here
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark Accessor Methods

- (NSString *)displayName
{
    return [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

#pragma mark Application Delegate Methods

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    // do some intialization application begin
    self.controller = [[YuplooController sharedController] retain];

    NSAssert(nil != self.controller, @"YuplooApplicationDelegate>-applicationDidFinishLaunching: controller cannot be nil.");
    
    [self.controller begin];
}

#pragma mark Actions


- (IBAction)showPreferences:(id)sender
{
	[self.controller.mainWindowController.preferenceController showWindow:sender];
}


@end
