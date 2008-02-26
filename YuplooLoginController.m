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
#import "YupooResult.h"

@interface YuplooLoginController (PrivateAPI)

- (void)loginSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void)authenticationNeededSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

@end

@implementation YuplooLoginController

@synthesize loginSheet, authenticationNeededSheet, loginStatus, mainWindowController, result;

- (id)initWithMainWindowController:(YuplooMainWindowController *)controller
{
    self = [super init];
    
    if (nil != self) {
        mainWindowController = controller;
    }
    
    return self;
}

- (void)finalize
{
    loginSheet = nil;
    authenticationNeededSheet = nil;
    [super finalize];
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
    Yupoo *yupoo = [[YuplooController sharedController] yupoo];
    [self setValue:[yupoo completeAuthentication:_frob] forKey:@"result"];
    [result addObserver:self forKeyPath:@"completed" options:(NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew) context:@"initiateAuthentication"];  
    [self showLoginSheet];    
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
    Yupoo *yupoo = [[YuplooController sharedController] yupoo];
    [self setValue:[yupoo initiateAuthentication] forKey:@"result"];
    _frob = nil;
    [result addObserver:self forKeyPath:@"completed" options:(NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew) context:@"initiateAuthentication"];  
    [self showLoginSheet];
}

- (void)check:(NSString *)token
{
    if (nil != token) {
        Yupoo *yupoo = [[YuplooController sharedController] yupoo];
        [self setValue:[yupoo authenticateWithToken:token] forKey:@"result"];
        // add self as the observer and context
        [result addObserver:self forKeyPath:@"completed" options:(NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew) context:@"authenticateWithToken"];
        // shows the authentication sheet
        [self showAuthenticationNeededSheet];
    }
    else {
        [self setValue:nil forKey:@"result"];
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)aContext
{
    id context = (id)aContext;
    
    if ([context isEqual:@"authenticateWithToken"]) {
        if ([[change objectForKey:NSKeyValueChangeNewKey] isEqual:[NSNumber numberWithBool:YES]]) {
            BOOL success = [object successful];
            if (success) {
                [NSApp endSheet:authenticationNeededSheet];
            }
        }
    }
    else if ([context isEqual:@"initiateAuthentication"]) {
        // the login form's button should do enable/disable the done button.
        if ([[change objectForKey:NSKeyValueChangeNewKey] isEqual:[NSNumber numberWithBool:YES]]) {
            BOOL success = [object successful];
            // if initiate fails, do that again.
            if (success) {
                _frob = [result authFrob];
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
            }
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
