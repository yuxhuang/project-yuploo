//
//  YupooObserver.h
//  Yuploo
//
//  Created by Felix Huang on 25/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface YupooObserver : NSObject {
    NSString *keyPath;
    id observer;
}

@property(readonly) id observer;
@property(readonly) NSString *keyPath;

- (id)initWithObserver:(id)anObserver keyPath:(NSString *)aKeyPath;

@end
