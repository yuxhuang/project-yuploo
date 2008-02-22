//
//  YPTree.h
//  Yupload
//
//  Created by Felix Huang on 09/11/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

@interface YPTree : NSObject {
    NSXMLElement *node;
}

+(id) treeForNode: (NSXMLElement*)aNode;

-(id) initWithNode: (NSXMLElement*)aNode;
-(NSArray*) findall: (NSString*)path;
-(YPTree*) find: (NSString*)path;
-(NSString*) findtext: (NSString*)path;

-(NSXMLElement*) node;
-(NSString*) tag;
-(NSDictionary*) attrib;
-(NSString*) text;

@end
