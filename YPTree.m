//
//  YPTree.m
//  Yupload
//
//  Created by Felix Huang on 09/11/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "YPTree.h"

@implementation YPTree

+(id) treeForNode: (NSXMLElement*)aNode {
    return [[[YPTree alloc] initWithNode:aNode] autorelease];
}

-(id) initWithNode:(NSXMLElement*)aNode {
    self = [super init];
    [aNode retain];
    node = aNode;
    return self;
}

- (void)dealloc
{
    [node release];
    [super dealloc];
}

-(NSArray*) findall: (NSString*)path {
    NSError *error;
    // return all nodes
    // TODO deal with error
    NSArray *nodes = [node nodesForXPath:path error:&error];
    NSMutableArray *trees = [NSMutableArray array];
    // get the enumerator
    NSEnumerator *enumerator = [nodes objectEnumerator];
    NSXMLElement *n;
    while (n = [enumerator nextObject]) {
        [trees addObject:[YPTree treeForNode:n]];
    }
    return trees;
}

-(YPTree*) find: (NSString*)path {
    NSError *error;
    // return all nodes
    // TODO deal with error
    NSArray *nodes = [node nodesForXPath:path error:&error];
    // if no node is found
    if ([nodes count] == 0)
        return nil;
    // get the first one
    return [YPTree treeForNode:[nodes objectAtIndex:0]];
}

-(NSString*) findtext: (NSString*)path {
    YPTree *tree = [self find: path];
    // non-existent node
    if (tree)
        return [tree text];
    else
        return nil;    
}

-(NSString*) tag {
    return [node name];
}

-(NSDictionary*) attrib {
    NSArray *attributes = [node attributes];
    NSMutableDictionary *attrib = [NSMutableDictionary dictionary];
    // no attribute is found
    if (!attributes)
        return nil;
    // enumerates all attributes
    NSEnumerator *enumerator = [attributes objectEnumerator];
    NSXMLNode *item;
    while (item=[enumerator nextObject]) {
        [attrib setObject:[item stringValue] forKey:[item name]];
    }
    return attrib;
}

-(NSString*) text {
    return [node stringValue];
}

-(NSXMLElement*) node {
    return node;
}

@end
