//
//  YuplooPhotoBrowserView.m
//  Yuploo
//
//  Created by Yuxing Huang on 11-08-21.
//  Copyright 2011 Webinit Consulting. All rights reserved.
//

#import "YuplooPhotoBrowserView.h"

@implementation YuplooPhotoBrowserView

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

#pragma mark Mac OS X 10.7
- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext: (NSDraggingContext)context
{
    NSDragOperation operation = NSDragOperationNone;
    
    switch (context) {
        case NSDraggingContextOutsideApplication:
            operation = NSDragOperationDelete;
            break;
        case NSDraggingContextWithinApplication:
            operation = NSDragOperationEvery;
            break;
    }
    
    return operation;
}

#pragma mark Mac OS X 10.6

//- (void)draggedImage:(NSImage *)anImage endedAt:(NSPoint)aPoint operation:(NSDragOperation)operation
//{
//    NSWindow *appWindow = [[NSApplication sharedApplication] keyWindow];
//    if (NSPointInRect(aPoint, appWindow.frame)) {
//        if ([super respondsToSelector:@selector(draggedImage:endedAt:operation:)]) {
//            [super draggedImage:anImage endedAt:aPoint operation:operation];
//        }
//    }
//    else {
//        // do nothing
//    }
//}
//
//- (void)draggedImage:(NSImage *)draggedImage movedTo:(NSPoint)screenPoint
//{
//    NSWindow *appWindow = [[NSApplication sharedApplication] keyWindow];
//    if (NSPointInRect(screenPoint, appWindow.frame)) {
//        if ([super respondsToSelector:@selector(draggedImage:movedTo:)]) {
//            [super draggedImage:draggedImage movedTo:screenPoint];
//        }
//    }
//    else {
//        // do nothing
//        ;
//    }
//}

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
    if (isLocal) {
        return NSDragOperationCopy | NSDragOperationLink | NSDragOperationGeneric | NSDragOperationPrivate;
    }
    else {
        return NSDragOperationNone;
    }
}

@end
