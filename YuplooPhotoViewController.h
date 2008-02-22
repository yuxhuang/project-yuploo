//
//  YuplooPhotoViewController.h
//  Yuploo
//
//  Created by Felix Huang on 22/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class YuplooMainWindowController;
@class MUPhotoView;

@interface YuplooPhotoViewController : NSViewController {
    NSMutableArray *photos;
    NSMutableIndexSet *selectionIndexes;
    IBOutlet MUPhotoView *photoView;
    IBOutlet NSArrayController *photoArrayController;
    YuplooMainWindowController *mainWindowController;
}

@property(readonly) NSMutableArray *photos;
@property(readonly) NSMutableIndexSet *selectionIndexes;
@property(readwrite,assign) MUPhotoView *photoView;
@property(readwrite,assign) NSArrayController *photoArrayController;
@property(readonly) YuplooMainWindowController *mainWindowController;

- (id)initWithMainWindowController:(YuplooMainWindowController *)controller;
- (void)loadNib;

@end
