//
//  yupoo.m
//  Yupload
//
//  Created by Felix Huang on 06/11/2007.
//  Copyright 2007 Felix Huang. All rights reserved.
//

#import "YPTree.h"
#import "PhotoAttribute.h"

#import "Yupoo.h"


@implementation Yupoo

@synthesize apiKey, secret, authToken, username, userId, frob, serviceUrl;

-(id) init {
    self = [super init];
    return self;
}

-(id) initWithApiKey:(NSString*)anApiKey secret:(NSString*)aSecret serviceUrl:(NSString*)aUrl {
    self = [self init];
    apiKey = anApiKey;
    secret = aSecret;
    serviceUrl = aUrl;
    return self;
}

-(NSDictionary*) encodeAndSign: (NSDictionary*) params {
    // the new params to return
    NSMutableDictionary *newParams = [NSMutableDictionary dictionary];
    // the sorted keys
    NSArray *sortedKeys = [[params allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSString *key, *value;
    NSMutableString *forHash = [NSMutableString stringWithString:secret];
    NSEnumerator *keyEnumerator = [sortedKeys objectEnumerator];
    while (key=[keyEnumerator nextObject]) {
        value = [[params objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [newParams setObject:value forKey:key];
        [forHash appendString:key];
        [forHash appendString:value];
    }
    
    // sign the call
    NSData *dataForHash = [forHash dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableData *dataDigest = [NSMutableData dataWithLength:MD5_DIGEST_LENGTH];
    MD5([dataForHash bytes], [dataForHash length], [dataDigest mutableBytes]);
    
    // transform to string
    const char *digest = [dataDigest bytes];
    NSString* sig = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			digest[0], digest[1], 
			digest[2], digest[3],
			digest[4], digest[5],
			digest[6], digest[7],
			digest[8], digest[9],
			digest[10], digest[11],
			digest[12], digest[13],
			digest[14], digest[15]];
    
    [newParams setValue:sig forKey:@"api_sig"];
    
    return newParams;
}

-(NSURLRequest*) buildRequest:(NSString*)url withParams:(NSDictionary*)params
{
    NSMutableString *requestUrl = [NSMutableString stringWithString:url];
    [requestUrl appendString:@"?"];
    NSEnumerator *keyEnumerator = [[params allKeys] objectEnumerator];
    NSString *key, *value;
    while (key=[keyEnumerator nextObject]) {
        value = [params objectForKey:key];
        [requestUrl appendFormat:@"%@=%@&", key, value];
    }
    NSMutableURLRequest * req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    return req;
}

- (NSURLRequest *)buildRequest:(NSString *)url withParams:(NSDictionary *)params withName:(NSString *)name withData:(NSData *)data withFile:(NSString *)filename
{
    NSMutableURLRequest *req = (NSMutableURLRequest *)[self buildRequest:url withParams:params];
    if (data) {
        NSString *boundary = @"pY9ELWSAe8XCSjTjVAyFRMd2HSrhmwoYWxPV";
        
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [req setValue:contentType forHTTPHeaderField:@"Content-Type"];
        [req setValue:YUPLOO_USER_AGENT forHTTPHeaderField:@"User-Agent"];
        
        [req setHTTPMethod:@"POST"];
        
        // determine the mime type
        CFStringRef extension = (CFStringRef)[filename pathExtension];
        CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(
                kUTTagClassFilenameExtension, extension, NULL);
        CFStringRef mime = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType);
        CFRelease(uti);
        
        // adding the body
        NSMutableData *postBody = [NSMutableData data];
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", name,
                filename] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", (NSString *)mime] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:data];
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [req setHTTPBody:postBody];
        CFRelease(mime);
    }
    return req;
}

// pre-condition: if isSync==YES, delegate is ignored. if isSync==NO, delegate should not be ignored.
//                reason should not be ignored.
- (id)sendRequest:(NSURLRequest *)request isSynchronous:(BOOL)isSync withDelegate:(id)delegate errorFor:(NSString **)reason
{
    // if synchronous request, the response will be returned as NSData
    if (isSync) {
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *responseData = [[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error] retain];
        // deal with error
        if (nil == responseData) {
            NSString *logEntry = [[NSString stringWithFormat:@"-sendRequest:(%d)[%@]", [error code], [error domain]] retain];
            NSLog(logEntry);
            *reason = [logEntry autorelease];
            return nil;
        }
        // ignore delegate
        // no error
        *reason = nil;
        return [responseData autorelease];
    }
    // if it is an asynchronous request, the connection will be returned.
    else {
        // delegate should not be nil here!
        NSURLConnection *connection = [[NSURLConnection connectionWithRequest:request delegate:delegate] retain];
        // deal with error
        if (nil == connection) {
            NSString *logEntry = [[NSString stringWithString:@"-sendRequest: Asynchronous connection cannot be created."] retain];
            NSLog(logEntry);
            *reason = [logEntry autorelease];
            return nil;
        }
        // no error
        *reason = nil;
        return [connection autorelease];
    }
}

-(YPTree*) parse:(NSXMLElement*)doc {
    return [YPTree treeForNode:doc];
}

- (id)call:(NSString*)method withParams:(NSDictionary*)callParams needToken:(BOOL)needToken {
    return [self call:method withParams:callParams needToken:needToken isSynchronous:YES delegate:nil withData:nil withFile:nil serviceUrl:nil];
}

- (id)call:(NSString*)method withParams:(NSDictionary*)callParams needToken:(BOOL)needToken isSynchronous:(BOOL)isSync delegate:(id)delegate
        withData:(NSData*)data withFile:(NSString *)filename serviceUrl:(NSString*)url {
    // get params
    NSMutableDictionary *params = nil;
    @try {
        if (callParams) {
            params = [NSMutableDictionary dictionaryWithDictionary:callParams];
        } else {
            params = [NSMutableDictionary dictionary];
        }
        // if method
        if (method) {
            [params setObject:method forKey:@"method"];
        }
        // add api key
        [params setObject:apiKey forKey:@"api_key"];
        // add the token if needed
        if (needToken) {
            [params setObject:authToken forKey:@"auth_token"];
        }
        // sign the call
        NSDictionary *signedParams = [self encodeAndSign:params];
        
        // build up the request
        NSURLRequest *request;
        if (nil != data) {
            request = [self buildRequest:(url?url:serviceUrl) withParams:signedParams withName:@"photo" withData:data withFile:filename];
        } else {
            request = [self buildRequest:(url?url:serviceUrl) withParams:signedParams];
        }
        NSLog(@"-call: %@", [[request URL] absoluteString]);
        // send the request
        // if synchronous request
        if (isSync) {
            NSString *reason = nil;
            NSData *response = [self sendRequest:request isSynchronous:YES withDelegate:nil errorFor:&reason];
            // parse synchronous output
            NSError *error = nil;
            NSXMLElement *root = [[[NSXMLDocument alloc] initWithData:response options:NSXMLDocumentTidyXML error:&error] rootElement];
            YPTree *tree = [YPTree treeForNode:root];
            [root release];
            return tree;
        }
        else {
            NSString *reason = nil;
            NSURLConnection *connection = [[self sendRequest:request isSynchronous:NO withDelegate:delegate errorFor:&reason] retain];
            if ([delegate respondsToSelector:@selector(setCurrentURLConnection:)]) {
                [delegate setCurrentURLConnection:connection];
            } 
            return [connection autorelease];
        }
        return nil;
    }
    @finally {
        [params release];
    }
    return nil;
}

/** authenticate the app */
-(NSURL*) authenticate {
    YPTree *tree = [self call:@"yupoo.auth.getFrob" withParams:nil needToken:NO];
    frob = [tree findtext:@"/rsp/frob"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:frob forKey:@"frob"];
    [dict setObject:@"write" forKey:@"perms"];
    [dict setObject:apiKey forKey:@"api_key"];
    NSDictionary *params = [self encodeAndSign:dict];
    NSURLRequest *req = [self buildRequest:@"http://www.yupoo.com/services/auth/" withParams:params];
    return [req URL];
}

/** confirm an authentication process */
-(BOOL) confirm
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:frob forKey:@"frob"];
    YPTree *tree = [self call:@"yupoo.auth.getToken" withParams:dict needToken:NO];
    NSLog(@"stat=%@", [[tree attrib] objectForKey:@"stat"]);
    authToken = [tree findtext:@"auth/token"];
    YPTree *user = [tree find:@"auth/user"];
    userId = [[user attrib] objectForKey:@"id"];
    username = [[user attrib] objectForKey:@"username"];
    NSString *nickname = [[user attrib] objectForKey:@"nickname"];
    NSLog(@"token: %@, username: %@, nickname: %@, user_id: %@", authToken, username, nickname, userId);
    return YES;
}

- (void)upload:(NSArray *)files delegate:(id)delegate
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    for (PhotoAttribute *attr in files) {
        NSData *data = [NSData dataWithContentsOfFile:attr.localPath];
        if (nil != attr.title) {
            [params setValue:attr.title forKey:@"title"];
        }
        if (nil != attr.description) {
            [params setValue:attr.description forKey:@"title"];
        }
        if (nil != attr.tags) {
            [params setValue:attr.tags forKey:@"tags"];
        }
        if (attr.isPublic) {
            [params setValue:@"1" forKey:@"is_public"];
        }
        else {
            [params setValue:@"0" forKey:@"is_public"];
        }
        if (attr.isContact) {
            [params setValue:@"1" forKey:@"is_contact"];
        }
        else {
            [params setValue:@"0" forKey:@"is_contact"];
        }
        if (attr.isFriend) {
            [params setValue:@"1" forKey:@"is_friend"];
        }
        else {
            [params setValue:@"0" forKey:@"is_friend"];
        }
        if (attr.isFamily) {
            [params setValue:@"1" forKey:@"is_family"];
        }
        else {
            [params setValue:@"0" forKey:@"is_family"];
        }

        [self call:nil withParams:params needToken:YES isSynchronous:NO delegate:delegate withData:data withFile:[attr.localPath lastPathComponent] serviceUrl:@"http://www.yupoo.com/api/upload/"];
    }
}

- (BOOL)recheck:(NSString *)token
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
        token, @"auth_token",
        nil];
    YPTree *result = [self call:@"yupoo.auth.checkToken" withParams:params needToken:NO];
    NSString *status = [[result attrib] objectForKey:@"stat"];

    NSLog(@"stat=%@", status);
    if ( [status isEqual:@"fail"] ) {
        YPTree *err = [result find:@"/rsp/err"];
        NSLog(@"Error[%@] %@", [[err attrib] objectForKey:@"code"], [[err attrib] objectForKey:@"msg"]);
        return NO;
    }
    
    YPTree *user = [result find:@"/rsp/auth/user"];
    userId = [[user attrib] objectForKey:@"id"];
    username = [[user attrib] objectForKey:@"username"];
    authToken = token;
    
    return YES;
}

-(void) dealloc
{
    [super dealloc];
}

@end

@implementation Yupoo (YupooDelegate)

- (void)setCurrentURLConnection:(NSURLConnection *)connection
{
    // do nothing
}

@end