//
//  YuplooPhotoViewController.h
//  Yuploo
//
//  Created by Felix Huang on 22/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class YuplooMainWindowController;
//@class MUPhotoView;

@interface YuplooPhotoViewController : NSViewController {
    NSMutableArray *photos;
    NSMutableIndexSet *selectionIndexes;
    IBOutlet NSCollectionView *photoView;
    IBOutlet NSArrayController *photoArrayController;
    YuplooMainWindowController *mainWindowController;
}

@property(readonly) NSMutableArray *photos;
@property(readonly) NSMutableIndexSet *selectionIndexes;
@property(nonatomic,retain) NSCollectionView *photoView;
@property(nonatomic,retain) NSArrayController *photoArrayController;
@property(readonly) YuplooMainWindowController *mainWindowController;

- (id)initWithMainWindowController:(YuplooMainWindowController *)controller;
- (void)loadNib;
- (void)addPhotoWithContentsOfFile:(NSString *)file;

@end

@interface PhotoBox : NSBox {

}

@end