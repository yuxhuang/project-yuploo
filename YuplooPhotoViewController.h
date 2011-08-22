//
//  IKBController.h
//  Yuploo
//
//  Created by Felix Huang on 24/04/08.
//  Copyright 2008 Two Fathoms Deep. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <AppKit/AppKit.h>

@class YuplooMainWindowController;
@class YuplooPhotoBrowserView;

@interface YuplooPhotoViewController : NSObject {
	IBOutlet NSView *view;
	IBOutlet YuplooPhotoBrowserView *browserView;
    IBOutlet NSView *dndLabel;
	NSMutableArray *browserImages;
	NSMutableArray *importedImages;
	YuplooMainWindowController *mainWindowController;
}

@property(retain) NSView *view;
@property(retain) YuplooPhotoBrowserView *browserView;
@property(retain) NSMutableArray *browserImages;
@property(retain) NSView *dndLabel;

- (void)loadNib;
- (void)removeAllPhotos;
- (void)removePhotos:(NSArray *)photos;

@end
