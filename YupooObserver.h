//
//  YupooObserver.h
//  Yuploo
//
//  Created by Felix Huang on 25/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface YupooObserver : NSObject {
    NSDictionary *keyPairs;
    id observer;
}

+ (id)observeWith:(id)observer keyPairs:(NSDictionary *)keyPairs;

- (id)initWith:(id)observer keyPairs:(NSDictionary *)keyPairs;

@end
