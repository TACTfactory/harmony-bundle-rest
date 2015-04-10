<@header?interpret />

#import "RestClientBase.h"
#import "AppDelegate.h"

static NSString* API_KEY;
static NSString* SCHEME_HTTP;
static NSString* SCHEME_HTTPS;
static BOOL isAuth;

@implementation RestClientBase

+ (void) initialize {
    SCHEME_HTTP = @"http";
    SCHEME_HTTPS = @"https";
    isAuth = NO;
}

+ (NSString*) API_KEY {
    return API_KEY;
}

+ (NSString*) SCHEME_HTTP {
    return SCHEME_HTTP;
}

+ (NSString*) SCHEME_HTTPS {
    return SCHEME_HTTPS;
}

+ (void) setIsAuth:(BOOL) auth {
    isAuth = auth;
}

+ (NSMutableDictionary*) buildRestJson:(NSString*) method {
    return [RestClientBase buildRestJson:method withParams:[NSMutableDictionary dictionary]] ;
}

+ (NSMutableDictionary*) buildRestJson:(NSString*) method
                           withParams:(NSMutableDictionary*) params {

    NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:params];
    [result setObject:method forKey:@"method"];

    return result;
}

- (id) initWithServiceName:(NSString*) urlHost {
    return [self initWithServiceName:urlHost withPort:80 withScheme:SCHEME_HTTP];
}

- (id) initWithServiceName:(NSString*) urlHost
                  withPort:(int) urlPort
                withScheme:(NSString*) urlScheme {
    if (!(self = [super init])) {
        return nil;
    }

    self->serviceName = urlHost;
    self->scheme = urlScheme;
    self->port = urlPort;

    return self;
}


- (void) invoke:(Verb) verb
       withPath:(NSString*) path
 withJsonParams:(NSMutableDictionary*) jsonParams
   withCallback:(void(^)(HttpResponse*)) callback{
	
    NSString* URL = [NSString stringWithFormat:@"%@://%@:%@/%@",
                     self->scheme,
                     self->serviceName,
                     [NSNumber numberWithInt:self->port],
                     path];
                     
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:URL]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    HttpResponse *httpResponse = [HttpResponse new ];

    if(verb == GET) {
        [manager GET:URL
          parameters:jsonParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
              httpResponse.result = responseObject;
              httpResponse.statusCode = [operation.response statusCode];
              callback(httpResponse);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            httpResponse.statusCode = [operation.response statusCode];
            callback(httpResponse);
        }];
    } else if(verb == PUT) {
        [manager PUT:URL
          parameters:jsonParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
              httpResponse.result = responseObject;
              httpResponse.statusCode = [operation.response statusCode];
              callback(httpResponse);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            httpResponse.statusCode = [operation.response statusCode];
            callback(httpResponse);
        }];
    } else if(verb == POST) {
        [manager POST:URL
          parameters:jsonParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
              httpResponse.result = responseObject;
              httpResponse.statusCode = [operation.response statusCode];
              callback(httpResponse);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            httpResponse.statusCode = [operation.response statusCode];
            callback(httpResponse);
        }];
    } else if(verb == DELETE) {
        [manager POST:URL
          parameters:jsonParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
              httpResponse.result = responseObject;
              httpResponse.statusCode = [operation.response statusCode];
              callback(httpResponse);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            httpResponse.statusCode = [operation.response statusCode];
            callback(httpResponse);
        }];
    }
}


@end
