//
//  YuplooMainWindowController.h
//  Yuploo
//
//  Created by Felix Huang on 21/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class YuplooLoginController;
@class YuplooPhotoViewController;
@class YuplooUploadController;
@class Yupoo;

@interface YuplooMainWindowController : NSWindowController {
    // properties to export
    YuplooLoginController *loginController;
    YuplooUploadController *uploadController;
    YuplooPhotoViewController *photoViewController;

    NSString *windowTitle;
    NSString *photoStatus;
    NSString *loginStatus;
    float loginProgressValue;
    BOOL loginProgressHidden;
    Yupoo *yupoo;
    
    IBOutlet NSObjectController *ownerObjectController;
    IBOutlet NSView *targetView;    
}

// properties
@property(retain) YuplooLoginController *loginController;
@property(retain) YuplooUploadController *uploadController;
@property(retain) YuplooPhotoViewController *photoViewController;
@property(copy) NSString *windowTitle;
@property(copy) NSString *photoStatus;
@property(copy) NSString *loginStatus;
@property CGFloat loginProgressValue;
@property BOOL loginProgressHidden;
@property(retain) NSObjectController *ownerObjectController;
@property(retain) NSView *targetView;
@property(readonly,retain) Yupoo *yupoo;

+ (id)mainWindowController;

- (IBAction)login:(id)sender;
- (IBAction)upload:(id)sender;

- (void)showLoginSheet;
- (void)showUploadSheet;

@end
