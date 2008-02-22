//
//  yupoo.h
//  Yupload
//
//  Created by Felix Huang on 06/11/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

@class YPTree;

@interface Yupoo : NSObject {
    // variables
@private
    NSString *apiKey, *secret, *authToken, *username, *userId, *frob, *serviceUrl;
}

@property(readwrite,assign) NSString *apiKey, *secret, *authToken, *username, *userId, *frob, *serviceUrl;

-(id) init;
-(void) dealloc;

/**
 * initialize with apiKey and secret provided
 */
-(id) initWithApiKey:(NSString*)anApiKey secret:(NSString*)aSecret serviceUrl:(NSString*)aUrl;

/**
 * call remote methods
 */
 -(NSURLRequest*) buildRequest:(NSString*)url withParams:(NSDictionary*)params;
 - (NSURLRequest *)buildRequest:(NSString *)url withParams:(NSDictionary *)params withName:(NSString *)name withData:(NSData *)data withFile:(NSString *)filename;
 - (id)sendRequest:(NSURLRequest *)request isSynchronous:(BOOL)isSync withDelegate:(id)delegate errorFor:(NSString **)reason;
-(id) call:(NSString*)method withParams:(NSDictionary*)callParams needToken:(BOOL)needToken;
-(id) call:(NSString*)method withParams:(NSDictionary*)params needToken:(BOOL)needToken isSynchronous:(BOOL)isSync delegate:(id)delegate
        withData:(NSData*)data withFile:(NSString *)filename serviceUrl:(NSString*)url;
/** sign a call */
-(NSDictionary*) encodeAndSign: (NSDictionary*) params;
/** parse xml result */
-(YPTree*) parse:(NSXMLElement*) doc;

- (NSURL *)authenticate;
- (BOOL)confirm;
- (void)upload:(NSArray *)files delegate:(id)delegate;
- (BOOL)recheck:(NSString *)token;

@end

@interface Yupoo (YupooDelegate)

- (void)setCurrentURLConnection:(NSURLConnection *)connection;

@end
