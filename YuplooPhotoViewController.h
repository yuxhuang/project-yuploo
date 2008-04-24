//
//  IKBController.h
//  Yuploo
//
//  Created by Felix Huang on 24/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>


@interface YuplooPhotoViewController : NSObject {
	IBOutlet IKImageBrowserView *browserView;
	NSMutableArray *browserImages;
	NSMutableArray *importedImages;
}

@property(retain) IKImageBrowserView *browserView;
@property(retain) NSMutableArray *browserImages;

@end
