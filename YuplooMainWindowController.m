//
//  YuplooMainWindowController
//  Yuploo
//
//  Created by Felix Huang on 21/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "YuplooMainWindowController.h"
#import "YuplooLoginController.h"
#import "YuplooUploadController.h"
#import "YuplooPhotoViewController.h"
#import "YuplooController.h"
#import "YuplooAttributeEditor.h"

@implementation YuplooMainWindowController

@synthesize loginController, uploadController, photoViewController, attributeEditor,
        windowTitle, photoStatus, loginStatus, loginProgressValue, loginProgressHidden,
        ownerObjectController, targetView, yupoo;

+ (id)mainWindowController
{
    return [[[self alloc] init] autorelease];
}

- (id)init
{
    self = [super initWithWindowNibName:@"MainWindow"];
    
    if (nil != self) {
        windowTitle = [[NSApp delegate] displayName];
        photoStatus = nil;
        loginStatus = nil;
        loginProgressValue = 0.0;
        loginProgressHidden = YES;
    }

	
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

	[loginController release];
	[uploadController release];
	[photoViewController release];
	[attributeEditor release];
    [super dealloc];
}

#pragma mark Window Loading Methods

- (void)windowDidLoad
{
	loginController = [[YuplooLoginController alloc] initWithMainWindowController:self];
	uploadController = [[YuplooUploadController alloc] initWithMainWindowController:self];
	photoViewController = [[YuplooPhotoViewController alloc] initWithMainWindowController:self];
	attributeEditor = [[YuplooAttributeEditor alloc] initWithMainWindowController:self];

	NSAssert(nil != loginController, @"YuplooMainWindowController>-init: loginController cannot be nil.");
	NSAssert(nil != photoViewController, @"YuplooMainWindowController>-init: photoViewController cannot be nil.");
	NSAssert(nil != attributeEditor, @"YuplooMainWindowController>-init: attributeEditor cannot be nil.");
    
    // add the photo view
	[photoViewController loadNib];
	[targetView setDocumentView:[photoViewController browserView]];

	// attribute editor
	[attributeEditor loadView];
	
    yupoo = [[YuplooController sharedController] yupoo];
    
    // make sure we have resized the photo view to match its 
    [[photoViewController browserView] setFrame:[targetView bounds]];
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
    [self.loginController login];
}

- (IBAction)upload:(id)sender
{
    [self.uploadController upload];
}

- (void)showLoginSheet
{
    [self.loginController showLoginSheet];
}

- (void)showUploadSheet
{

}


@end
