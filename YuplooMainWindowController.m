//
//  YuplooMainWindowController
//  Yuploo
//
//  Created by Felix Huang on 21/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "YuplooMainWindowController.h"
#import "YuplooLoginController.h"

@implementation YuplooMainWindowController

@synthesize loginController, uploadController,
        windowTitle,
        ownerObjectController;

+ (id)mainWindowController
{
    return [[[self alloc] init] autorelease];
}

- (id)init
{
    self = [super initWithWindowNibName:@"MainWindow"];
    
    if (nil != self) {
        loginController = [[YuplooLoginController alloc] initWithMainWindowController:self];
        windowTitle = [[[NSApp delegate] displayName] copy];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [loginController release];
    [windowTitle release];
    [super dealloc];
}

#pragma mark Window Loading Methods

- (void)windowDidLoad
{
}

#pragma mark Window Delegate Methods

- (void)windowWillClose:(NSNotification *)notification
{
    [ownerObjectController setContent:nil];
    [NSApp terminate:self];
}

#pragma mark Accessor Methods

#pragma mark UI Actions

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)userInterfaceItem
{
    SEL action = [userInterfaceItem action];
    
    if (action == @selector(login:)) {
        // check login status
        return YES;
    }
    else if (action == @selector(upload:)) {
        // check with upload status
        return YES;
    }
    else {
        return NO;
    }
}

- (IBAction)login:(id)sender
{
    [self showLoginSheet];
}

- (IBAction)upload:(id)sender
{
    [self showUploadSheet];
}

- (void)showLoginSheet
{
    [self.loginController showLoginSheet];
}

- (void)showUploadSheet
{

}


@end
