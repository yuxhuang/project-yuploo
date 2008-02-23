//
//  YuplooController.m
//  Yuploo
//
//  Created by Felix Huang on 21/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "YuplooController.h"
#import "YuplooMainWindowController.h"
#import "YuplooLoginController.h"
#import "Yupoo.h"

@implementation YuplooController

@synthesize mainWindowController, yupoo;

static YuplooController *sharedController = nil;

+ (id)sharedController
{
    @synchronized(self) {
        if (nil == sharedController) {
            [[self alloc] init];
        }
    }
    
    return sharedController;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (nil == sharedController) {
            sharedController = [super allocWithZone:zone];
            return sharedController;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return UINT_MAX;
}

- (void)release
{
    // do nothing
}

- (id)autorelease
{
    return self;
}

- (id)init
{
    self = [super init];
    
    if (nil != self) {
       self.mainWindowController = [YuplooMainWindowController mainWindowController];
       yupoo = [[Yupoo alloc] initWithApiKey:YUPLOO_API_KEY
                secret:YUPLOO_API_SECRET
                serviceUrl:YUPLOO_API_REST];
    }
    
    return self;
}

- (void)dealloc
{
    [self setMainWindowController:nil];
    [yupoo release];
    [super dealloc];
}

#pragma mark Convenience Methods

- (void)begin
{
    [self.mainWindowController.window makeKeyAndOrderFront:self];
    // try to login with stored authentication token
    NSString *token = [[YuplooController sharedController] savedAuthToken];
    [self.mainWindowController.loginController check:token];
}

- (NSString *)savedAuthToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:@"authToken"];
}

- (void)saveToken:(NSString *)token
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:token forKey:@"authToken"];
}

@end
