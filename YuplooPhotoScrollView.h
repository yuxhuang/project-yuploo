//
//  YuplooPhotoScrollView.h
//  Yuploo
//
//  Created by Felix Huang on 03/03/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class YuplooPhotoViewController;

@interface YuplooPhotoScrollView : NSScrollView {
    IBOutlet YuplooPhotoViewController *photoViewController;
}

@property(readwrite,assign) YuplooPhotoViewController *photoViewController;

@end
