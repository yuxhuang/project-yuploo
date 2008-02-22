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
    
    IBOutlet NSObjectController *ownerObjectController;
    IBOutlet NSView *targetView;    
}

// properties
@property(readwrite,retain) YuplooLoginController *loginController;
@property(readwrite,retain) YuplooUploadController *uploadController;
@property(readwrite,retain) YuplooPhotoViewController *photoViewController;
@property(readwrite,copy) NSString *windowTitle;
@property(readwrite,copy) NSString *photoStatus;
@property(readwrite,retain) NSString *loginStatus;
@property(readwrite) float loginProgressValue;
@property(readwrite) BOOL loginProgressHidden;
@property(readwrite,retain) NSObjectController *ownerObjectController;
@property(readwrite,retain) NSView *targetView;

+ (id)mainWindowController;

- (IBAction)login:(id)sender;
- (IBAction)upload:(id)sender;

- (void)showLoginSheet;
- (void)showUploadSheet;

@end
