//
//  YuplooLoginController.m
//  Yuploo
//
//  Created by Felix Huang on 21/02/08.
//  Copyright 2008 Two Fathoms Deep. All rights reserved.
//

#import "YuplooLoginController.h"
#import "YuplooController.h"
#import "Yupoo.h"
#import "YupooSession.h"
#import "YuplooMainWindowController.h"

@interface YuplooLoginController (PrivateAPI)

- (void)loginSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void)authenticationNeededSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

@end

@implementation YuplooLoginController

@synthesize loginSheet, authenticationNeededSheet, loginStatus, mainWindowController, result, authenticationNeeded;

- (id)initWithMainWindowController:(YuplooMainWindowController *)controller
{
    self = [super init];
    
    if (nil != self) {
        authenticationNeeded = YES;
        yupoo = [[YuplooController sharedController] yupoo];
        mainWindowController = controller;
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)loadNib
{
    [NSBundle loadNibNamed:@"Login" owner:self];
}

- (void)loadYupoo
{
    if (nil == yupoo)
        yupoo = [[YuplooController sharedController] yupoo];
        
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
    [self loadYupoo];
    [self setValue:[yupoo completeAuthentication:_frob] forKey:@"result"];
    [result observe:self forKeyPath:@"completed" options:(NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew) context:@"completeAuthentication"];  
	[result begin];
}

- (IBAction)authenticationNeededSheetCancel:(id)sender
{
    [self setValue:nil forKey:@"result"];
    [NSApp endSheet:authenticationNeededSheet];
}

- (IBAction)authenticationNeededSheetOK:(id)sender
{
    [self setValue:nil forKey:@"result"];
    [NSApp endSheet:authenticationNeededSheet];
  // go on login sheet
    [self login];
}

- (void)login
{
    [self loadYupoo];
    [self setValue:[yupoo initiateAuthentication] forKey:@"result"];
	[_frob release];
    _frob = nil;
    mainWindowController.loginStatus = nil;
    [[YuplooController sharedController] saveToken:nil];
    [result observe:self forKeyPath:@"completed" options:(NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew) context:@"initiateAuthentication"];
    [self showLoginSheet];
	[result begin];
}

- (void)check:(NSString *)token
{
	[token retain];
    if (nil != token) {
        authenticationNeeded = NO;
        [self loadYupoo];
        [self setValue:[yupoo authenticateWithToken:token] forKey:@"result"];
        // add self as the observer and context
        [result observe:self forKeyPath:@"completed" options:(NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew) context:@"authenticateWithToken"];
        // shows the authentication sheet
        [self showAuthenticationNeededSheet];
		[result begin];
    }
    else {
        authenticationNeeded = YES;
        [self setValue:nil forKey:@"result"];
        [self showAuthenticationNeededSheet];
		[result begin];
    }
	[token release];
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)aContext
{
    id context = (id)aContext;
    
    if ([context isEqual:@"authenticateWithToken"]) {
        if ([[change objectForKey:NSKeyValueChangeNewKey] isEqual:[NSNumber numberWithBool:YES]]) {
            BOOL success = [object successful];
            if (success) {
                [NSApp endSheet:authenticationNeededSheet];
                self.mainWindowController.loginStatus = [result authUserName];
            }
        }
    }
    else if ([context isEqual:@"initiateAuthentication"]) {
        // the login form's button should do enable/disable the done button.
        if ([[change objectForKey:NSKeyValueChangeNewKey] isEqual:[NSNumber numberWithBool:YES]]) {
            BOOL success = [object successful];
            // if initiate fails, do that again.
            if (success) {
                _frob = [[result authFrob] copy];
                // open the url
                [[NSWorkspace sharedWorkspace] openURL:[result webAuthenticationURL]];
            }
            else {
                // close the sheet, then do again.
                [NSApp endSheet:loginSheet];
                [self login];
            }
        }
    }
    else if ([context isEqual:@"completeAuthentication"]) {
        // here we should automatically close the sheet
        if ([[change objectForKey:NSKeyValueChangeNewKey] isEqual:[NSNumber numberWithBool:YES]]) {
            BOOL success = [object successful];
            if (success) {
                [NSApp endSheet:loginSheet];
                self.mainWindowController.loginStatus = [result authUserName];
                [[YuplooController sharedController] saveToken:[result authToken]];
            }
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
