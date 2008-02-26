//
//  YuplooLoginController.h
//  Yuploo
//
//  Created by Felix Huang on 21/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class YuplooMainWindowController;
@class YupooResult;

@interface YuplooLoginController : NSObject {
    YuplooMainWindowController *mainWindowController;
    IBOutlet NSWindow *loginSheet;
    IBOutlet NSWindow *authenticationNeededSheet;
    NSString *loginStatus;
    YupooResult *result;
    NSString *_frob;
}

@property(readwrite,assign) NSWindow *loginSheet;
@property(readwrite,assign) NSWindow *authenticationNeededSheet;
@property(readwrite,assign) NSString *loginStatus;
@property(readonly) YuplooMainWindowController *mainWindowController;
@property(readonly) YupooResult *result;

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
