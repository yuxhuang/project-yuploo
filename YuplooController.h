//
//  YuplooController.h
//  Yuploo
//
//  Created by Felix Huang on 21/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class YuplooMainWindowController;
@class Yupoo;

@interface YuplooController : NSObject {
    YuplooMainWindowController *mainWindowController;
    Yupoo *yupoo;
}

@property(nonatomic,retain) YuplooMainWindowController *mainWindowController;
@property(readonly,retain) Yupoo *yupoo;

+ (id)sharedController;

- (void)begin;
- (NSString *)savedAuthToken;
- (void)saveToken:(NSString *)token;

@end
