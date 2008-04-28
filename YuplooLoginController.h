//
//  YuplooLoginController.h
//  Yuploo
//
//  Created by Felix Huang on 21/02/08.
//  Copyright 2008 Two Fathoms Deep. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class YuplooMainWindowController;
@class YupooResult;
@class Yupoo;

@interface YuplooLoginController : NSObject {
    YuplooMainWindowController *mainWindowController;
    IBOutlet NSWindow *loginSheet;
    IBOutlet NSWindow *authenticationNeededSheet;
    NSString *loginStatus;
    YupooResult *result;
    Yupoo *yupoo;
    NSString *_frob;
    BOOL authenticationNeeded;
}

@property(retain) NSWindow *loginSheet;
@property(retain) NSWindow *authenticationNeededSheet;
@property(retain) NSString *loginStatus;
@property(readonly) YuplooMainWindowController *mainWindowController;
@property(readonly) YupooResult *result;
@property(readonly) BOOL authenticationNeeded;

- (id)initWithMainWindowController:(YuplooMainWindowController *)controller;
- (YuplooMainWindowController *)mainWindowController;

- (void)showLoginSheet;
- (void)showAuthenticationNeededSheet;

- (IBAction)loginSheetCancel:(id)sender;
- (IBAction)loginSheetOK:(id)sender;
- (IBAction)authenticationNeededSheetCancel:(id)sender;
- (IBAction)authenticationNeededSheetOK:(id)sender;

- (void)login;
- (void)check:(NSString *)token;

@end
