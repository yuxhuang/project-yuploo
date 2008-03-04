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
@property(readwrite,assign) YuplooLoginController *loginController;
@property(readwrite,assign) YuplooUploadController *uploadController;
@property(readwrite,assign) YuplooPhotoViewController *photoViewController;
@property(readwrite,copy) NSString *windowTitle;
@property(readwrite,copy) NSString *photoStatus;
@property(readwrite,copy) NSString *loginStatus;
@property(readwrite) float loginProgressValue;
@property(readwrite) BOOL loginProgressHidden;
@property(readwrite,assign) NSObjectController *ownerObjectController;
@property(readwrite,assign) NSView *targetView;
@property(readonly) Yupoo *yupoo;

+ (id)mainWindowController;

- (IBAction)login:(id)sender;
- (IBAction)upload:(id)sender;

- (void)showLoginSheet;
- (void)showUploadSheet;

@end
