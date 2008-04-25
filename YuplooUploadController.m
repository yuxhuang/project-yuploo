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

	photoQueue = [[NSMutableArray alloc] initWithArray:photos];
	resultStack = [[NSMutableArray alloc] init];
	uploadedStack = [[NSMutableArray alloc] init];

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
	if (!result.successful) {
		[uploadedStack removeObjectAtIndex:([uploadedStack count] - 1)];
	}
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
    PhotoItem *item = [[photoQueue objectAtIndex:0] retain];
    self.uploadStatus = [[[item path] lastPathComponent] copy];
    result = [yupoo uploadPhoto:item.photo];
	// eject it

	[uploadedStack addObject:item];
	[photoQueue removeObjectAtIndex:0];
	[uploadStatus release];
    [item release];
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