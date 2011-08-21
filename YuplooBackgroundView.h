//
//  YuplooImageBrowserScrollView.h
//  Yuploo
//
//  Created by Yuxing Huang on 11-08-20.
//  Copyright 2011 Webinit Consulting. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface YuplooBackgroundView : NSView
{
    NSImage *image;
    
    @private BOOL drawsBackground;
}

@property (assign) BOOL drawsBackground;


@end
