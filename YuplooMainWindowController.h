//
//  YuplooMainWindowController.h
//  Yuploo
//
//  Created by Felix Huang on 21/02/08.
//  Copyright 2008 Two Fathoms Deep. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class YuplooLoginController;
@class YuplooPhotoViewController;
@class YuplooUploadController;
@class YuplooAttributeEditor;
@class YuplooPreferencePanelController;
@class Yupoo;

@interface YuplooMainWindowController : NSWindowController {
    // properties to export
    YuplooLoginController *loginController_;
    YuplooUploadController *uploadController_;
    YuplooPhotoViewController *photoViewController_;
	YuplooAttributeEditor *attributeEditor_;
	YuplooPreferencePanelController *preferenceController_;

    NSString *windowTitle;
    NSString *photoStatus;
    NSString *loginStatus;
    CGFloat loginProgressValue;
    BOOL loginProgressHidden;
    Yupoo *yupoo;
    
    IBOutlet NSObjectController *ownerObjectController;
    IBOutlet NSScrollView *targetView;
}

// properties
@property(readonly,nonatomic) YuplooLoginController *loginController;
@property(readonly,nonatomic) YuplooUploadController *uploadController;
@property(readonly,nonatomic) YuplooPhotoViewController *photoViewController;
@property(readonly,nonatomic) YuplooAttributeEditor *attributeEditor;
@property(readonly,nonatomic) YuplooPreferencePanelController *preferenceController;

@property(copy) NSString *windowTitle;
@property(copy) NSString *photoStatus;
@property(copy) NSString *loginStatus;
@property CGFloat loginProgressValue;
@property BOOL loginProgressHidden;
@property(retain) NSObjectController *ownerObjectController;
@property(retain) NSScrollView *targetView;
@property(readonly,retain) Yupoo *yupoo;

+ (id)mainWindowController;

- (IBAction)login:(id)sender;
- (IBAction)upload:(id)sender;

- (void)showLoginSheet;
- (void)showUploadSheet;

@end
