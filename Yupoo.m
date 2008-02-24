//
//  Yupoo.m
//  Yuploo
//
//  Created by Felix Huang on 22/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Yupoo.h"
#import "YupooResult.h"
#import "Photo.h"
#include <openssl/md5.h>

@interface Yupoo (PrivateAPI)
// build up URL and requests
- (NSURL *)URLWith:(NSString *)aURL params:(NSDictionary *)params;
- (NSURLRequest *)requestWithURL:(NSString *)aURL params:(NSDictionary *)params timeoutInterval:(NSTimeInterval)timeout;
- (NSURLRequest *)photoUploadRequestWithURL:(NSString *)aURL params:(NSDictionary *)params photo:(Photo *)aPhoto timeoutInterval:(NSTimeInterval)timeout;

// call
- (YupooResult *)call:(NSString *)method params:(NSDictionary *)params needToken:(BOOL)needToken;

// send the request
- (YupooResult *)callRequest:(NSURLRequest *)aRequest;

// convinience methods
- (NSDictionary *)paramsEncodedAndSigned:(NSDictionary *)oldParams;

@end

@implementation Yupoo

@synthesize authToken, username, userId, nickname, timeout;

+ (id)yupooWithApiKey:(NSString *)anApiKey secret:(NSString *)aSecret
{
    return [[[self class] alloc] initWithApiKey:anApiKey secret:aSecret];
}

- (id)initWithApiKey:(NSString *)anApiKey secret:(NSString *)aSecret
{
    self = [super init];
    
    if (nil != self) {
        apiKey = [anApiKey copy];
        secret = [aSecret copy];
        timeout = 60.0; // default timeout
    }
    
    return self;
}

- (id)connectRest:(NSString *)aRestURL upload:(NSString *)anUploadURL authentication:(NSString *)anAuthenticationURL
{
    
    restURL = [aRestURL copy];
    uploadURL = [anUploadURL copy];
    authenticationURL = [anAuthenticationURL copy];
    
    return self;
}

- (YupooResult *)authenticateWithToken:(NSString *)aToken
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
            aToken, @"auth_token",
            nil];
    
    return [self call:@"yupoo.auth.checkToken" params:params needToken:NO];
}

- (NSURL *)authenticate
{
    YupooResult *result = [self call:@"yupoo.auth.getFrob" params:nil needToken:NO];
    
}

- (YupooResult *)confirm
{

}

- (YupooResult *)uploadPhoto:(Photo *)photo
{

}



@end


@implementation Yupoo (PrivateAPI)

// build up URL and requests
- (NSURL *)URLWith:(NSString *)aURL params:(NSDictionary *)params
{
    // copy the url first
    NSMutableString *url = [NSMutableString stringWithString:aURL];
    
    // add the query question mark
    [url appendString:@"?"];
    
    // let's build it
    for (NSString *key in [params allKeys]) {
        NSString *value = [params objectForKey:key];
        [url appendFormat:@"%@=%@", key, value];
    }
    
    return [NSURL URLWithString:url];
}

- (NSURLRequest *)requestWithURL:(NSString *)aURL params:(NSDictionary *)params timeoutInterval:(NSTimeInterval)aTimeout
{
    NSDictionary *signedParams = [self paramsEncodedAndSigned:params];
    
    return [NSURLRequest requestWithURL:[self URLWith:aURL params:signedParams]
            cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:aTimeout];
}

- (NSURLRequest *)photoUploadRequestWithURL:(NSString *)aURL params:(NSDictionary *)params photo:(Photo *)photo timeoutInterval:(NSTimeInterval)aTimeout
{
    NSAssert(nil != photo, @"photo cannot be nil.");
    
    // build up params with photo attributes
    NSMutableDictionary *buildingParams;
    if (nil == params) {
        buildingParams = [NSMutableDictionary dictionary];
    }
    else {
        buildingParams = [NSMutableDictionary dictionaryWithDictionary:params];
    }
    
    if (nil != photo.title) {
        [buildingParams setObject:photo.title forKey:@"title"];
    }
    if (nil != photo.description) {
        [buildingParams setObject:photo.description forKey:@"title"];
    }
    if (nil != photo.tags) {
        [buildingParams setObject:photo.tags forKey:@"tags"];
    }
    if (photo.public) {
        [buildingParams setObject:@"1" forKey:@"is_public"];
    }
    else {
        [buildingParams setObject:@"0" forKey:@"is_public"];
    }
    if (photo.contact) {
        [buildingParams setObject:@"1" forKey:@"is_contact"];
    }
    else {
        [buildingParams setObject:@"0" forKey:@"is_contact"];
    }
    if (photo.friend) {
        [buildingParams setObject:@"1" forKey:@"is_friend"];
    }
    else {
        [buildingParams setObject:@"0" forKey:@"is_friend"];
    }
    if (photo.family) {
        [buildingParams setObject:@"1" forKey:@"is_family"];
    }
    else {
        [buildingParams setObject:@"0" forKey:@"is_family"];
    }
    
    // build the request url
    NSDictionary *signedParams = [self paramsEncodedAndSigned:buildingParams];
    NSURL *url = [self URLWith:aURL params:signedParams];
    // build the request
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
            cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:aTimeout];
    
    // go ahead to put the photo
    // set content-type, user-agent and boundary
    NSString *boundary = @"pY9ELWSAe8XCSjTjVAyFRMd2HSrhmwoYWxPV";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setValue:YUPLOO_USER_AGENT forHTTPHeaderField:@"User-Agent"];
    [request setHTTPMethod:@"POST"];

    // test if we use our native WIMultiPartInputStream
    if (photo.useMultiPartStream) {
        #warning FIXME use multipart stream
    }
    else {
        NSError *error = nil;
        #warning FIXME deal with possible error here
        NSString *mime = [[NSWorkspace sharedWorkspace] typeOfFile:photo.path error:&error];
        
        // adding the body
        NSMutableData *postBody = [NSMutableData data];
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:
                @"Content-Disposition: form-data; name=\"photo\"; filename=\"%@\"\r\n", photo.nameForDownload] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", (NSString *)mime] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[photo data]];
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:postBody];        
    }
    
    return request;
}

// send the request
- (YupooResult *)callRequest:(NSURLRequest *)aRequest
{
    YupooResult *result = [YupooResult resultOfRequest:aRequest inYupoo:self];
    return result;
}

- (YupooResult *)call:(NSString *)method params:(NSDictionary *)params needToken:(BOOL)needToken
{
    NSMutableDictionary *buildingParams = nil;
    
    if (nil == params) {
        buildingParams = [NSMutableDictionary dictionary];
    }
    else {
        buildingParams = [NSMutableDictionary dictionaryWithDictionary:params];
    }
    
    // add method if exists
    if (nil != method) {
        [buildingParams setObject:method forKey:@"method"];
    }
    
    // api key
    [buildingParams setObject:apiKey forKey:@"api_key"];
    
    // token
    if (self.authToken && needToken) {
        [buildingParams setObject:self.authToken forKey:@"auth_token"];
    }
    
    // request
    NSURLRequest *request = [self requestWithURL:restURL params:buildingParams timeoutInterval:self.timeout];
    
    return [YupooResult resultOfRequest:request inYupoo:self];
}

// convinience methods
- (NSDictionary *)paramsEncodedAndSigned:(NSDictionary *)oldParams
{
    // params dictionary to hold them
    NSMutableDictionary *newParams = [NSMutableDictionary dictionary];
    // because of the signing algorithm, we have to sort out the keys
    NSArray *sortedKeys = [[oldParams allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    // the string for signing
    NSMutableString *forHash = [NSString stringWithString:secret];
    
    // go ahead to encode and build the string
    for (NSString *key in sortedKeys) {
        // escape the query parameter by percentage representation before hashing
        NSString *value = [[oldParams objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        // done
        [newParams setObject:value forKey:key];
        [forHash appendFormat:@"%@%@", key, value];
    }
    
    // i do not hold oldParams any more
    oldParams = nil;
    
    // sign it
    NSData *dataForHash = [forHash dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableData *dataForDigest = [NSMutableData dataWithLength:MD5_DIGEST_LENGTH];
    
    // MD5!!
    MD5([dataForHash bytes], [dataForHash length], [dataForDigest mutableBytes]);
    
    // transform the digest into hexidemical string
    const char *digest = [dataForDigest bytes];
    NSString* signature = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			digest[0], digest[1], 
			digest[2], digest[3],
			digest[4], digest[5],
			digest[6], digest[7],
			digest[8], digest[9],
			digest[10], digest[11],
			digest[12], digest[13],
			digest[14], digest[15]];
    
    // add it to the parameters list
    [newParams setObject:signature forKey:@"api_sig"];
    
    return newParams;
}

@end