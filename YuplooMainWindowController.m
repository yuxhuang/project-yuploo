//
//  YuplooMainWindowController
//  Yuploo
//
//  Created by Felix Huang on 21/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "YuplooMainWindowController.h"
#import "YuplooLoginController.h"
#import "YuplooPhotoViewController.h"
#import "YuplooController.h"

@implementation YuplooMainWindowController

@synthesize loginController, uploadController, photoViewController,
        windowTitle, photoStatus, loginStatus, loginProgressValue, loginProgressHidden,
        ownerObjectController, targetView;

+ (id)mainWindowController
{
    return [[[self alloc] init] autorelease];
}

- (id)init
{
    self = [super initWithWindowNibName:@"MainWindow"];
    
    if (nil != self) {
        loginController = [[YuplooLoginController alloc] initWithMainWindowController:self];
        photoViewController = [[YuplooPhotoViewController alloc] initWithMainWindowController:self];
        windowTitle = [[[NSApp delegate] displayName] copy];
        photoStatus = nil;
        loginStatus = nil;
        loginProgressValue = 0.0;
        loginProgressHidden = YES;
    }
    NSAssert(nil != windowTitle, @"YuplooMainWindowController>-init: windowTitle cannot be nil.");
    NSAssert(nil != loginController, @"YuplooMainWindowController>-init: loginController cannot be nil.");
    NSAssert(nil != photoViewController, @"YuplooMainWindowController>-init: photoViewController cannot be nil.");
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self.loginController release];
    [self.photoViewController release];
    
    [self.windowTitle release];
    
    [super dealloc];
}

#pragma mark Window Loading Methods

- (void)windowDidLoad
{
    // add the photo view
    [self.photoViewController loadNib];
    [self.targetView addSubview:[self.photoViewController view]];
    
    // make sure we have resized the photo view to match its superview
    [[self.photoViewController view] setFrame:[self.targetView bounds]];
}

#pragma mark Window Delegate Methods

- (void)windowWillClose:(NSNotification *)notification
{
    [self.ownerObjectController setContent:nil];
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
