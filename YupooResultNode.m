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
        xmlElement = [anElement retain];
    }
    
    return self;
}

- (void)dealloc {
	[xmlElement release];
	[super dealloc];
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
	[name retain];
    NSXMLNode *attrNode = [[xmlElement attributeForName:name] retain];
	[name release];
    
    // no such an attribute
    if (nil == attrNode) {
        return nil;
    }
    
    NSString *value = [[attrNode stringValue] copy];
	[attrNode release];
	
	return [value autorelease];
}

// here we accept a XPath
- (YupooResultNode *)find:(NSString *)path
{
	[path retain];
    NSError *error = nil;
    NSArray *nodes = [xmlElement nodesForXPath:path error:&error];
    
    // deal with error
    if (nil == nodes) {
        _LOG([error localizedDescription]);
		[path release];
        return nil;
    }
    
    if (0 == [nodes count]) {
        _LOG(@"No correspondence.");
		[path release];
        return nil;
    }
	
	[path release];    
    return [[[YupooResultNode alloc] initWithXMLElement:[nodes objectAtIndex:0]] autorelease];
}

// here we accept a XPath
- (NSArray *)findall:(NSString *)path
{
	[path retain];
	
    NSError *error = nil;
    // return all nodes
    NSArray *nodes = [xmlElement nodesForXPath:path error:&error];
    
    // error
    if (nil == nodes) {
        _LOG([error localizedDescription]);
		[path release];
        return nil;
    }

    NSMutableArray *nodesFound = [[NSMutableArray alloc] init];
    
    for (NSXMLElement *child in nodes) {
        [nodesFound addObject:
                [[[YupooResultNode alloc] initWithXMLElement:child] autorelease]];
    }
    
	[path release];
    return [nodesFound autorelease];
}

- (NSString *)$:(NSString *)path
{
	[path retain];
    // it must not be nil
    NSAssert(nil != path, @"Path cannot be nil");
    
    // so let's deal with a modified version of XPath representation
    NSArray *components = [path componentsSeparatedByString:@":"];
    
    // no components?
    if (1 == [components count]) {
        NSString *value = [[self find:path] text];
		[path release];
		return value;
    }
    else if (2 == [components count]) {
    
        NSString *main = [[components objectAtIndex:0] copy];
        NSString *attributeName = [[components objectAtIndex:1] copy];
        YupooResultNode *node = [self find:main];
        
        // no correspondence?
        if (nil == node) {
            // return nil
			[main release];
			[attributeName release];
			[path release];
			return nil;
        }
        
        // attribute name's length is zero?
        if (0 == [attributeName length]) {
            // nil
			[main release];
			[attributeName release];
			[path release];
            return nil;
        }
        
        NSString *value = [node attr:attributeName];
		[main release];
		[attributeName release];
		return value;
    }
    else {
        // Wow! More than two components! This is an exception!
        _LOG(@"Only two components are accepted.");
		[path release];
        return nil;
    }
}

- (NSArray *)$$:(NSString *)path
{
    return nil;
}

- (NSDictionary *)$A:(NSString *)path
{
	[path retain];
    YupooResultNode *node = [self find:path];
	[path release];
    
    if (nil == node)
        return nil;

    return [node attrs];
}

@end
