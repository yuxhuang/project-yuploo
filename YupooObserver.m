//
//  YupooObserver.m
//  Yuploo
//
//  Created by Felix Huang on 25/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "YupooObserver.h"
#import "YupooResult.h"

@implementation YupooObserver

+ (id)observeWith:(id)observer keyPairs:(NSDictionary *)keyPairs
{
    return [[[self class] alloc] initWith:observer keyPairs:keyPairs];
}

- (id)initWith:(id)anObserver keyPairs:(NSDictionary *)aKeyPairs
{
    self = [super init];
    
    if (nil != self) {
        observer = anObserver;
        keyPairs = aKeyPairs;
    }
    
    return self;    
}

// observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)observee change:(NSDictionary *)change
        context:(void *)context
{
    // observe the change, then trigger related changes
    // here we can ignore the changes of keyPath/change
    for(NSString *key in [keyPairs allKeys]) {
        [observer setValue:[observee valueForKeyPath:key] forKeyPath:[keyPairs objectForKey:key]];
    }
    
    // then cancel the observation
//    [observee overlook:keyPath withObject:self];
    [super observeValueForKeyPath:keyPath ofObject:observee change:change context:context];
}
@end
