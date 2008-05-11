//
//  YuplooApplicationDelegate.h
//  Yuploo
//
//  Created by Felix Huang on 21/02/08.
//  Copyright 2008 Two Fathoms Deep. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class YuplooController;

@interface YuplooApplicationDelegate : NSObject {
    YuplooController *controller;
}

@property(readwrite,retain) YuplooController *controller;

- (IBAction)showPreferences:(id)sender;

@end
