//
//  YuplooMainWindowController.h
//  Yuploo
//
//  Created by Felix Huang on 21/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class YuplooLoginController;
@class YuplooUploadController;

@interface YuplooMainWindowController : NSWindowController {
    // properties to export
    YuplooLoginController *loginController;
    YuplooUploadController *uploadController;

    NSString *windowTitle;
    
    IBOutlet NSObjectController *ownerObjectController;
    
}

// properties
@property(readwrite,assign) YuplooLoginController *loginController;
@property(readwrite,assign) YuplooUploadController *uploadController;
@property(readwrite,copy) NSString *windowTitle;
@property(readwrite,assign) NSObjectController *ownerObjectController;

+ (id)mainWindowController;

- (IBAction)login:(id)sender;
- (IBAction)upload:(id)sender;

- (void)showLoginSheet;
- (void)showUploadSheet;

@end
