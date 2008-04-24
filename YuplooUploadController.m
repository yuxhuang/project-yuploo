//
//  YuplooUploadController.m
//  Yuploo
//
//  Created by Felix Huang on 04/03/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "YuplooUploadController.h"
#import "YuplooController.h"
#import "YuplooMainWindowController.h"
#import "YuplooPhotoViewController.h"
#import "YupooResult.h"
#import "Photo.h"
#import "Yupoo.h"

@interface YuplooUploadController (PrivateAPI)

- (void)uploadSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

// returns nil if queue is empty
- (YupooResult *)uploadAndEjectFirstPhotoInQueue;

@end

@implementation YuplooUploadController

@synthesize uploadSheet, uploadStatus, mainWindowController,
        result, thanksButtonEnabled;

- (id)initWithMainWindowController:(YuplooMainWindowController *)controller
{
    self = [super init];
    
    if (nil != self) {
        yupoo = [[YuplooController sharedController] yupoo];
        mainWindowController = controller;
        self.thanksButtonEnabled = NO;
    }
    
    return self;
}

- (void)finalize
{
    uploadSheet = nil;
    [super finalize];
}

- (void)loadNib
{
    [NSBundle loadNibNamed:@"Upload" owner:self];
}

- (void)upload
{
    #warning XXX do upload things
    // fill the photos queue with photos (in the photo controller)
    photoQueue = [[[mainWindowController photoViewController] photos] retain];
    
    result = [self uploadAndEjectFirstPhotoInQueue];
    if (nil != result) {
        [result addObserver:self forKeyPath:@"completed" options:(NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew) context:nil];
    }
    [self showUploadSheet];
}

- (void)showUploadSheet
{
    if (nil == uploadSheet) [self loadNib];
    #warning XXX do some initialization here?
    
    [NSApp beginSheet:uploadSheet modalForWindow:[[self mainWindowController] window]
            modalDelegate:self didEndSelector:@selector(uploadSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (IBAction)uploadSheetCancel:(id)sender
{
    #warning XXX clean up upload mess
    [NSApp endSheet:uploadSheet];
}

- (IBAction)uploadSheetThanks:(id)sender
{
    [NSApp endSheet:uploadSheet];
}

@end

@implementation YuplooUploadController (PrivateAPI)

- (void)uploadSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
}

- (YupooResult *)uploadAndEjectFirstPhotoInQueue
{
    // photo queue is empty
    if ([photoQueue count] == 0) {
        self.uploadStatus = @"No photos.";
        return nil;
    }

    // get the photo
    Photo *photo = [[photoQueue objectAtIndex:0] retain];
    self.uploadStatus = [[[photo path] lastPathComponent] copy];
    result = [yupoo uploadPhoto:photo];
    [photo release];
    return result;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // perfect!
    if(result.successful) {
        // release the result first
        [result release];
        // get the next result
        result = [self uploadAndEjectFirstPhotoInQueue];
        // has next photo to upload
        if (nil != result) {
            // observe the new result
            [result addObserver:self forKeyPath:@"completed" options:(NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew) context:nil];
        }
        // no photo left
        else {
            self.thanksButtonEnabled = YES;
        }
    }
    // no, i haven't something wrong
    else {
        #warning XXX deal with this something
        
    }
}


@end