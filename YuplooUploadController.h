//
//  YuplooUploadController.h
//  Yuploo
//
//  Created by Felix Huang on 04/03/08.
//  Copyright 2008 Two Fathoms Deep. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class YuplooMainWindowController;
@class YupooSession;
@class Yupoo;
@class PhotoItem;

@interface YuplooUploadController : NSObject {
    YuplooMainWindowController *mainWindowController;
    IBOutlet NSWindow *uploadSheet;
	IBOutlet NSProgressIndicator *progressIndicator;
    
    NSString *uploadStatus;
    BOOL thanksButtonEnabled;
	BOOL cancelButtonEnabled;
    
    YupooSession *result;
    Yupoo *yupoo;

    NSMutableArray *photoQueue;
	NSMutableArray *uploadedStack;
	NSMutableArray *resultStack;
	PhotoItem *uploadingPhoto;
}

@property(readwrite,retain) NSWindow *uploadSheet;
@property(readwrite,copy) NSString *uploadStatus;
@property(readonly) YuplooMainWindowController *mainWindowController;
@property(readonly) YupooSession *result;
@property(assign) BOOL thanksButtonEnabled;
@property(assign) BOOL cancelButtonEnabled;

- (void)upload;
- (void)showUploadSheet;

- (IBAction)uploadSheetThanks:(id)sender;
- (IBAction)uploadSheetCancel:(id)sender;

@end
