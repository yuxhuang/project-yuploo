//
//  YuplooLoginController.m
//  Yuploo
//
//  Created by Felix Huang on 21/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "YuplooLoginController.h"
#import "YuplooController.h"
#import "Yupoo.h"

@interface YuplooLoginController (PrivateAPI)

- (void)loginSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void)authenticationNeededSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

@end

@implementation YuplooLoginController

@synthesize loginSheet, authenticationNeededSheet, loginStatus, mainWindowController;

- (id)initWithMainWindowController:(YuplooMainWindowController *)controller
{
    self = [super init];
    
    if (nil != self) {
        mainWindowController = controller;
    }
    
    return self;
}

- (void)dealloc
{
    [loginSheet release];
    [authenticationNeededSheet release];
    [super dealloc];
}

- (void)loadNib
{
    [NSBundle loadNibNamed:@"Login" owner:self];
}

- (YuplooMainWindowController *)mainWindowController
{
    return mainWindowController;
}

- (void)showLoginSheet
{
    if (nil == loginSheet) [self loadNib];
    #warning FIXME do some intialization here
    
    [NSApp beginSheet:loginSheet modalForWindow:[[self mainWindowController] window]
            modalDelegate:self didEndSelector:@selector(loginSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)showAuthenticationNeededSheet
{
    if (nil == authenticationNeededSheet) [self loadNib];
    
    #warning FIXME do some intialization here
    
    [NSApp beginSheet:authenticationNeededSheet modalForWindow:[[self mainWindowController] window]
            modalDelegate:self didEndSelector:@selector(authenticationNeededSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (IBAction)loginSheetCancel:(id)sender
{
    [NSApp endSheet:loginSheet];
}

- (IBAction)loginSheetOK:(id)sender
{
    [NSApp endSheet:loginSheet];
}

- (IBAction)authenticationNeededSheetCancel:(id)sender
{
    [NSApp endSheet:authenticationNeededSheet];
}

- (IBAction)authenticationNeededSheetOK:(id)sender
{
    [NSApp endSheet:authenticationNeededSheet];
    // go on login sheet
    [self login];
}

- (void)login
{
    [self showLoginSheet];
    
}

- (void)check:(NSString *)token
{
    if (nil != token) {
        Yupoo *yupoo = [[YuplooController sharedController] yupoo];
        // if the authToken is invalid
        if (![yupoo recheck:token]) {
            // tell something about authentication needed
            [self showAuthenticationNeededSheet];
        }
    }
    else {
        [self showAuthenticationNeededSheet];
    }
}

@end

@implementation YuplooLoginController (PrivateAPI)

- (void)loginSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
}

- (void)authenticationNeededSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
}

@end
