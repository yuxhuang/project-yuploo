//
//  IKBController.h
//  Yuploo
//
//  Created by Felix Huang on 24/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@class YuplooMainWindowController;

@interface YuplooPhotoViewController : NSObject {
	IBOutlet NSView *view;
	IBOutlet IKImageBrowserView *browserView;
	NSMutableArray *browserImages;
	NSMutableArray *importedImages;
	YuplooMainWindowController *mainWindowController;
}

@property(retain) NSView *view;
@property(retain) IKImageBrowserView *browserView;
@property(retain) NSMutableArray *browserImages;

- (void)loadNib;
- (void)removeAllPhotos;

@end
