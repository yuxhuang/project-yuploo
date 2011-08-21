//
//  YuplooImageBrowserScrollView.m
//  Yuploo
//
//  Created by Yuxing Huang on 11-08-20.
//  Copyright 2011 Webinit Consulting. All rights reserved.
//

#import "YuplooBackgroundView.h"

@implementation YuplooBackgroundView

@synthesize drawsBackground;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        drawsBackground = YES;
    }
    
    return self;
}

- (void)awakeFromNib
{
    image = [[NSImage imageNamed:@"DropHere.png"] retain];
    drawsBackground = YES;
}

- (void) dealloc
{
    [image release];
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Fill in background Color
    CGContextRef context = (CGContextRef) [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetRGBFillColor(context, 0.227,0.251,0.337,0.8); // some mysterious colour
    CGContextFillRect(context, NSRectToCGRect(dirtyRect));
    
    if (drawsBackground) {
        // drop the image on top
        CGImageRef im = [image CGImageForProposedRect:nil context:[NSGraphicsContext currentContext] hints:nil];
        // counting the rect
        CGRect rect = CGRectMake(self.bounds.size.width / 2 - 200, self.bounds.size.height / 2 - 200, 400, 400);
        
        CGContextDrawImage(context, rect, im);
    }
    
}


@end
