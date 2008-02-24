//
//  YupooResultNode.h
//  Yuploo
//
//  Created by Felix Huang on 23/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface YupooResultNode : NSObject {
    NSXMLElement *xmlElement;
}

// initialization
- (id)initWithXMLElement:(NSXMLElement *)xmlElement;

// node
- (NSString *)name;
- (NSString *)text;
- (NSDictionary *)attrs;
- (NSString *)attr:(NSString *)name;

// first correspondence
- (NSString *)$:(NSString *)path;
// all correspondences
- (NSArray *)$$:(NSString *)path;
// all attributes of the first correspondence
- (NSDictionary *)$A:(NSString *)path;
// search for the first correspondence in XPath
- (YupooResultNode *)find:(NSString *)path;
// search for all correspondences in XPath
- (NSArray *)findall:(NSString *)path;


@end
