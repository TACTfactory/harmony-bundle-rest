<@header?interpret />

#import "RestClientBase.h"
#import "AppDelegate.h"

static NSString *API_KEY;
static NSString *SCHEME_HTTP;
static NSString *SCHEME_HTTPS;
static bool isAuth;
static NSString *FILE_PARAM;

@implementation RestClientBase

+ (void) initialize {
    SCHEME_HTTP = @"http";
    SCHEME_HTTPS = @"https";
    isAuth = false;
    FILE_PARAM = @"file";
}

+ (NSString *) API_KEY {
    return API_KEY;
}

+ (NSString *) SCHEME_HTTP {
    return SCHEME_HTTP;
}

+ (NSString *) SCHEME_HTTPS {
    return SCHEME_HTTPS;
}

+ (void) setIsAuth:(bool) auth {
    isAuth = auth;
}

- (id) initWithServiceName:(NSString *) urlHost {
    return [self initWithServiceName:urlHost withPort:80 withScheme:SCHEME_HTTP];
}

- (id) initWithServiceName:(NSString *) urlHost
                  withPort:(int) urlPort
                withScheme:(NSString *) urlScheme {
    if (!(self = [super init])) {
        return nil;
    }

    self->serviceName = urlHost;
    self->scheme = urlScheme;
    self->port = urlPort;

    return self;
}

- (void) invoke:(Verb) verb
       withPath:(NSString *) path
 withJsonParams:(NSMutableDictionary *) jsonParams
   withCallback:(void(^)(HttpResponse *)) callback {

    NSString *URL = [NSString stringWithFormat:@"%@://%@:%@/%@",
                     self->scheme,
                     self->serviceName,
                     [NSNumber numberWithInt:self->port],
                     path];

    void (^success)(AFHTTPRequestOperation *operation, id responseObject) = [self getSuccessCallback:callback];
    void (^failure)(AFHTTPRequestOperation *operation, NSError *error) = [self getFailureCallback:callback];

    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]
                                              initWithBaseURL:[NSURL URLWithString:URL]];

    if ([jsonParams objectForKey:FILE_PARAM] != nil) {
        [self executeRequestFile:manager verb:verb url:URL params:jsonParams success:success failure:failure];
    } else {
        [self executeRequest:manager verb:verb url:URL params:jsonParams success:success failure:failure];
    }
}

- (void (^)(AFHTTPRequestOperation *operation, NSError *error)) getSuccessCallback:(void(^)(HttpResponse *)) callback {
    void (^success)(AFHTTPRequestOperation *operation, id responseObject) =
    ^(AFHTTPRequestOperation *operation, id responseObject) {

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            HttpResponse *httpResponse = [HttpResponse new];
            httpResponse.result = responseObject;
            httpResponse.statusCode = operation.response.statusCode;

            if (callback != nil) {
                callback(httpResponse);
            }
        });
    };

    return success;
}

- (void (^)(AFHTTPRequestOperation *operation, NSError *error)) getFailureCallback:(void(^)(HttpResponse *)) callback {
    void (^failure)(AFHTTPRequestOperation *operation, NSError *error) =
    ^(AFHTTPRequestOperation *operation, NSError *error) {

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^ {
            NSLog(@"Error: %@", error);
            HttpResponse *httpResponse = [HttpResponse new];
            httpResponse.result = nil;
            httpResponse.statusCode = [operation.response statusCode];

            if (callback != nil) {
                callback(httpResponse);
            }
        });
    };

    return failure;
}

- (void) executeRequest:(AFHTTPRequestOperationManager *) manager
                   verb:(Verb) verb
                    url:(NSString *) url
                 params:(NSMutableDictionary *) params
                success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {

    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    if(verb == GET) {
        [manager GET:url parameters:params success:success failure:failure];
    } else if(verb == PUT) {
        [manager PUT:url parameters:params success:success failure:failure];
    } else if(verb == POST) {
        [manager POST:url parameters:params success:success failure:failure];
    } else if(verb == DELETE) {
        [manager DELETE:url parameters:params success:success failure:failure];
    } else if (verb == PATCH) {
        [manager PATCH:url parameters:params success:success failure:failure];
    }
}

- (void) executeRequestFile:(AFHTTPRequestOperationManager *) manager
                   verb:(Verb) verb
                    url:(NSString *) url
                 params:(NSMutableDictionary *) params
                success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {

    NSURL *filePath = [NSURL fileURLWithPath:[params objectForKey:FILE_PARAM]];

    [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:filePath
                                   name:FILE_PARAM
                                  error:nil];
    } success:success failure:failure];
}

@end
