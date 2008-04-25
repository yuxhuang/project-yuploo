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
#import "PhotoItem.h"

@interface YuplooUploadController (PrivateAPI)

- (void)uploadSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

// returns nil if queue is empty
- (YupooResult *)uploadAndEjectFirstPhotoInQueue;

@end

@implementation YuplooUploadController

@synthesize uploadSheet, uploadStatus, mainWindowController,
        result, cancelButtonEnabled, thanksButtonEnabled;

- (id)initWithMainWindowController:(YuplooMainWindowController *)controller
{
    self = [super init];
    
    if (nil != self) {
        YuplooController *ypcontroller = [YuplooController sharedController];
		yupoo = ypcontroller.yupoo;
        mainWindowController = [controller retain];
        self.thanksButtonEnabled = NO;
    }
    
    return self;
}

- (void)dealloc
{
	[mainWindowController release];
    [uploadSheet release];
    [super dealloc];
}

- (void)loadNib
{
    [NSBundle loadNibNamed:@"Upload" owner:self];
}

- (void)upload
{
	// set thanks button
	self.cancelButtonEnabled = YES;
	self.thanksButtonEnabled = NO;
    // fill the photos queue with photos (in the photo controller)
	NSArray *photos = mainWindowController.photoViewController.browserImages;

	photoQueue = [[NSMutableArray alloc] init];
	resultStack = [[NSMutableArray alloc] init];
	uploadedStack = [[NSMutableArray alloc] init];

	for (PhotoItem *item in photos) {
		[photoQueue addObject:item.photo];
	}
    
    result = [self uploadAndEjectFirstPhotoInQueue];
    if (nil != result) {
        [result addObserver:self forKeyPath:@"completed" options:(NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew) context:nil];
		[resultStack addObject: result];
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
	// clear photo queue
	// clear observers
	for (YupooResult *re in resultStack) {
		[re removeObserver:self forKeyPath:@"completed"];
	}
	// remove uploaded photos in browser
	[mainWindowController.photoViewController removePhotos:uploadedStack];
    [sheet orderOut:self];

	[uploadedStack release];
	[resultStack release];
    [photoQueue release];
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
	[uploadStatus release];
    [photo release];
	// insert it to done stack
	[uploadedStack addObject:photo];
	// eject it
	[photoQueue removeObjectAtIndex:0];
    return result;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // perfect!
    if(result.successful) {
        // get the next result
        result = [self uploadAndEjectFirstPhotoInQueue];
        // has next photo to upload
        if (nil != result) {
            // observe the new result
            [result addObserver:self forKeyPath:@"completed" options:(NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew) context:nil];
        }
        // no photo left
        else {
			self.uploadStatus = @"Done.";
			self.cancelButtonEnabled = NO;
            self.thanksButtonEnabled = YES;
        }
    }
    // no, i haven't something wrong
    else {
        #warning XXX deal with this something
        
    }
}


@end