//
//  YuplooUploadController.h
//  Yuploo
//
//  Created by Felix Huang on 04/03/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class YuplooMainWindowController;
@class YupooResult;
@class Yupoo;

@interface YuplooUploadController : NSObject {
    YuplooMainWindowController *mainWindowController;
    IBOutlet NSWindow *uploadSheet;
    
    NSString *uploadStatus;
    BOOL thanksButtonEnabled;
    NSMutableArray *photoQueue;
    
    YupooResult *result;
    Yupoo *yupoo;
}

@property(readwrite,retain) NSWindow *uploadSheet;
@property(readwrite,copy) NSString *uploadStatus;
@property(readonly) YuplooMainWindowController *mainWindowController;
@property(readonly) YupooResult *result;
@property BOOL thanksButtonEnabled;

- (void)upload;
- (void)showUploadSheet;

- (IBAction)uploadSheetThanks:(id)sender;
- (IBAction)uploadSheetCancel:(id)sender;

@end
