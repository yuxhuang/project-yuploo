//
//  Yupoo.m
//  Yuploo
//
//  Created by Felix Huang on 22/02/08.
//  Copyright 2008 Two Fathoms Deep. All rights reserved.
//

#import "Yupoo.h"
#import "YupooSession.h"
#import "YupooObserver.h"
#import "Photo.h"
#import "GDataHTTPFetcher.h"
#import "GDataProgressMonitorInputStream.h"
#import "GDataMIMEDocument.h"
#include <openssl/md5.h>

@interface Yupoo (PrivateAPI)
// build up URL and requests

- (NSURLRequest *)requestWithURL:(NSString *)aURL params:(NSDictionary *)params timeoutInterval:(NSTimeInterval)timeout;

// call
- (YupooSession *)call:(NSString *)method params:(NSDictionary *)params needToken:(BOOL)needToken;

// convinience methods


@end

@implementation Yupoo

@synthesize apiKey, authToken, username, userId, nickname, timeout, authenticationURL, restURL, uploadURL;

- (id)initWithApiKey:(NSString *)anApiKey secret:(NSString *)aSecret
{
    self = [super init];
    
    if (nil != self) {
        apiKey = [anApiKey copy];
        secret = [aSecret copy];
        frob = nil;
        timeout = 60.0; // default timeout
    }
    
    return self;
}

- (void)dealloc {
	[apiKey release];
	[secret release];
	[frob release];
	[restURL release];
	[uploadURL release];
	[authenticationURL release];
	[super dealloc];
}

- (id)connectRest:(NSString *)aRestURL upload:(NSString *)anUploadURL authentication:(NSString *)anAuthenticationURL
{
    
    restURL = [aRestURL copy];
    uploadURL = [anUploadURL copy];
    authenticationURL = [anAuthenticationURL copy];
    
    return self;
}

- (YupooSession *)authenticateWithToken:(NSString *)aToken
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
            aToken, @"auth_token",
            nil];
    
    YupooSession *result = [[self call:@"yupoo.auth.checkToken" params:params needToken:NO] retain];
    
    [result observe:self forKeyPath:@"completed" options:(NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew)
            context:@"authenticateWithToken"];
	
    return [result autorelease];
}
   
- (YupooSession *)initiateAuthentication
{
    YupooSession *result = [[self call:@"yupoo.auth.getFrob" params:nil needToken:NO] retain];
    
    [result observe:self forKeyPath:@"completed" options:(NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew)
            context:@"initiateAuthentication"];
	
    return [result autorelease];
}

- (YupooSession *)completeAuthentication:(NSString *)aFrob
{
    frob = [aFrob copy];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
            frob, @"frob", nil];
    
    YupooSession *result = [[self call:@"yupoo.auth.getToken" params:params needToken:NO] retain];
    
    [result observe:self forKeyPath:@"completed" options:(NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew)
            context:@"completeAuthentication"];
	
    return [result autorelease];
}

- (YupooSession *)uploadPhoto:(Photo *)photo
{
	[photo retain];

	// generate the params
    NSMutableDictionary *buildingParams = [[NSMutableDictionary alloc] init];
    
    // api key
    [buildingParams setObject:apiKey forKey:@"api_key"];
    
    // token
    if (self.authToken) {
        [buildingParams setObject:self.authToken forKey:@"auth_token"];
    }
    
	// photo attributes
	if (nil != photo.title) {
        [buildingParams setObject:photo.title forKey:@"title"];
    }
    if (nil != photo.description) {
        [buildingParams setObject:photo.description forKey:@"description"];
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
    
	NSDictionary *signedParams = [[self paramsEncodedAndSigned:buildingParams] retain];
	
	// use mime document to send the request
	GDataMIMEDocument *document = [GDataMIMEDocument MIMEDocument];
	
	// add parameters
	for (NSString *key in [signedParams allKeys]) {
		NSString *value = [signedParams objectForKey:key];
		[document addPartWithHeaders:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"form-data; name=\"%@\"", key], @"Content-Disposition",
									  nil]
								body:[value dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	// add the file
	// adding the body
	NSError *error = nil;
	NSString *uti = [[NSWorkspace sharedWorkspace] typeOfFile:photo.path error:&error];
	NSString *mime;
	if ([uti isEqualToString: (NSString *)kUTTypeJPEG]) {
		mime = @"image/jpeg";
	}
	else if ([uti isEqualToString: (NSString *)kUTTypePNG]) {
		mime = @"image/png";
	}
	
	[document addPartWithHeaders:[NSDictionary dictionaryWithObjectsAndKeys:
								  [NSString stringWithFormat:@"form-data; name=\"photo\"; filename=\"%@\"", photo.nameForDownload], @"Content-Disposition",
								  mime, @"Content-Type",
								  nil]
							body:[photo data]];
	
	NSInputStream *input;
	unsigned long long length;
	NSString *boundary;
	// generate the stream
	[document generateInputStream:&input length:&length boundary:&boundary];
	// generate the request
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:uploadURL]];
	[request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
	[request setValue:[NSString stringWithFormat:@"%d", length] forHTTPHeaderField:@"Content-Length"];
	[request setValue:YUPLOO_USER_AGENT forHTTPHeaderField:@"User-Agent"];
	
	// initiate the session
	YupooSession *session = [[YupooSession alloc] initWithRequest:request
															yupoo:self
													 uploadStream:input
														   length:length];
	
	[photo release];
	return [session autorelease];
}


// build up URL and requests
- (NSURL *)URLWith:(NSString *)aURL params:(NSDictionary *)params
{
	[params retain];
    // copy the url first
    NSMutableString *url = [NSMutableString stringWithString:aURL];
    
    // add the query question mark
    [url appendString:@"?"];
    
    // let's build it
    for (NSString *key in [params allKeys]) {
        NSString *value = [params objectForKey:key];
        [url appendFormat:@"%@=%@&", key, value];
    }
    
	[params release];
    return [NSURL URLWithString:url];
}

- (NSDictionary *)paramsEncodedAndSigned:(NSDictionary *)oldParams
{
	[oldParams retain];
    // params dictionary to hold them
    NSMutableDictionary *newParams = [[NSMutableDictionary alloc] init];
    // because of the signing algorithm, we have to sort out the keys
    NSArray *sortedKeys = [[oldParams allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    // the string for signing
    NSMutableString *forHash = [NSMutableString stringWithString:secret];
    
    // go ahead to encode and build the string
    for (NSString *key in sortedKeys) {
        // escape the query parameter by percentage representation before hashing
//        NSString *value = [[oldParams objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSString *value = [oldParams objectForKey:key];
        // done
        [newParams setObject:value forKey:key];
        [forHash appendFormat:@"%@%@", key, value];
    }
    
    // i do not hold oldParams any more
    [oldParams release];
    
    // sign it
    NSData *dataForHash = [forHash dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    NSMutableData *dataForDigest = [NSMutableData dataWithLength:MD5_DIGEST_LENGTH];
    
    // MD5!!
    MD5([dataForHash bytes], [dataForHash length], [dataForDigest mutableBytes]);
    
    // transform the digest into hexidemical string
    const char *digest = [dataForDigest bytes];
    NSMutableString *ms;
    if (digest) {
        ms = [NSMutableString string];
        for (int i = 0; i < MD5_DIGEST_LENGTH; i++) {
            [ms appendFormat: @"%02x", (unsigned char)(digest[i])];
        }
    }
    NSString *signature = [NSString stringWithString:ms];
    
    // add it to the parameters list
    [newParams setObject:signature forKey:@"api_sig"];
    
    return [newParams autorelease];
}

@end


@implementation Yupoo (PrivateAPI)


- (NSURLRequest *)requestWithURL:(NSString *)aURL params:(NSDictionary *)params timeoutInterval:(NSTimeInterval)aTimeout
{
	[params retain];
    NSDictionary *signedParams = [[self paramsEncodedAndSigned:params] retain];
	[params release];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[self URLWith:aURL params:[signedParams autorelease]]];
	[request setValue:YUPLOO_USER_AGENT forHTTPHeaderField:@"User-Agent"];
	
    return [request autorelease];
}

- (YupooSession *)call:(NSString *)method params:(NSDictionary *)params needToken:(BOOL)needToken
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
    
    return [YupooSession resultOfRequest:request inYupoo:self];
}



// convinience methods
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)aContext
{
    id context = (id)aContext;

    if ([context isEqual:@"initiateAuthentication"]) {
        [self setValue:[object authFrob] forKeyPath:@"frob"];
    }
    else if ([context isEqual:@"completeAuthentication"]) {
        [self setValue:[object authToken] forKeyPath:@"authToken"];
        [self setValue:[object authUserId] forKeyPath:@"userId"];
        [self setValue:[object authUserName] forKeyPath:@"username"];
        [self setValue:[object authNickName] forKeyPath:@"nickname"];
    }
    else if ([context isEqual:@"authenticateWithToken"]) {
        [self setValue:[object authToken] forKeyPath:@"authToken"];
        [self setValue:[object authUserId] forKeyPath:@"userId"];
        [self setValue:[object authUserName] forKeyPath:@"username"];
        [self setValue:[object authNickName] forKeyPath:@"nickname"];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


@end