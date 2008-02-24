//
//  YupooResultNode.m
//  Yuploo
//
//  Created by Felix Huang on 23/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "YupooResultNode.h"


@implementation YupooResultNode

- (id)initWithXMLElement:(NSXMLElement *)anElement
{
    self = [super init];
    
    if (nil != self) {
        xmlElement = anElement;
    }
    
    return self;
}

- (NSString *)name {
    return [xmlElement name];
}

- (NSString *)text {
    return [xmlElement stringValue];
}

- (NSDictionary *)attrs {
    NSArray *attributes = [xmlElement attributes];
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    
    // no attribute is found
    if (nil == attributes)
        return attrs; // just return the empty dictionary
    
    // get all items
    for (NSXMLNode *item in attributes) {
        [attrs setObject:[item stringValue] forKey:[item name]];
    }
    
    return attrs;
}

- (NSString *)attr:(NSString *)name
{
    NSXMLNode *attrNode = [xmlElement attributeForName:name];
    
    // no such an attribute
    if (nil == attrNode) {
        return nil;
    }
    
    return [attrNode stringValue];
}

// here we accept a XPath
- (YupooResultNode *)find:(NSString *)path
{
    NSError *error = nil;
    NSArray *nodes = [xmlElement nodesForXPath:path error:&error];
    
    // deal with error
    if (nil == nodes) {
        _LOG([error localizedDescription]);
        return nil;
    }
    
    if (0 == [nodes count]) {
        _LOG(@"No correspondence.");
        return nil;
    }
    
    return [[YupooResultNode alloc] initWithXMLElement:[nodes objectAtIndex:0]];
}

// here we accept a XPath
- (NSArray *)findall:(NSString *)path
{
    NSError *error = nil;
    // return all nodes
    NSArray *nodes = [xmlElement nodesForXPath:path error:&error];
    
    // error
    if (nil == nodes) {
        _LOG([error localizedDescription]);
        return nil;
    }

    NSMutableArray *nodesFound = [NSMutableArray array];
    
    for (NSXMLElement *child in nodes) {
        [nodesFound addObject:
                [[YupooResultNode alloc] initWithXMLElement:child]];
    }
    
    return nodesFound;
}

- (NSString *)$:(NSString *)path
{
    // it must not be nil
    NSAssert(nil != path, @"Path cannot be nil");
    
    // so let's deal with a modified version of XPath representation
    NSArray *components = [path componentsSeparatedByString:@":"];
    
    // no components?
    if (1 == [components count]) {
        return [[self find:path] text];
    }
    else if (2 == [components count]) {
    
        NSString *main = [components objectAtIndex:0];
        NSString *attributeName = [components objectAtIndex:1];
        YupooResultNode *node = [self find:main];
        
        // no correspondence?
        if (nil == node) {
            // return nil
            return nil;
        }
        
        // attribute name's length is zero?
        if (0 == [attributeName length]) {
            // nil
            return nil;
        }
        
        return [node attr:attributeName];
    }
    else {
        // Wow! More than two components! This is an exception!
        _LOG(@"Only two components are accepted.");
        return nil;
    }
}

- (NSArray *)$$:(NSString *)path
{
    return nil;
}

- (NSDictionary *)$A:(NSString *)path
{
    YupooResultNode *node = [self find:path];
    
    if (nil == node)
        return nil;

    return [node attrs];
}

@end
