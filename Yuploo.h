/*
 *  Yuploo.h
 *  Yuploo
 *
 *  Created by Felix Huang on 22/02/08.
 *  Copyright 2008 Two Fathoms Deep. All rights reserved.
 *
 */

#define YUPLOO_USER_AGENT       @"Yuploo/1.0 (Mac OS X)"
#define YUPLOO_API_KEY          @"c164b4d221e29299d3f565b2ceb66226"
#define YUPLOO_API_SECRET       @"dqb6kf9up4uw1mdy"
#define YUPLOO_API_REST         @"http://www.yupoo.com/api/rest/"
#define YUPLOO_API_UPLOAD       @"http://www.yupoo.com/api/upload/"
#define YUPLOO_API_AUTHENTICATION @"http://www.yupoo.com/services/auth/"


#define _LOG(msg) NSLog(@"%@>%@ %@", [self className], NSStringFromSelector(_cmd), (msg))