<@header?interpret />

#import "RPCClient.h"
#import "AppDelegate.h"

static NSString* API_KEY;
static NSString* SCHEME_HTTP;
static NSString* SCHEME_HTTPS;
static BOOL isAuth;

AFJSONRPCClient* httpClient;

@implementation RPCClient

+ (void) initialize {
    if ([AppDelegate IS_DEBUG]) {
        API_KEY = @"52005559c5d0e83e7575bb0fc2e4eba63ed18a7e";
    } else {
        API_KEY = @"89c321be3bb4c07d7d739c7588e9407e5c9b59a0";
    }
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

+ (NSMutableDictionary*) buildRpcJson:(NSString*) method {
    return [RPCClient buildRpcJson:method withParams:[NSMutableDictionary dictionary]] ;
}

+ (NSMutableDictionary*) buildRpcJson:(NSString*) method
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
   withCallback:(void(^)(NSObject*)) callback{

    NSString* URL = [NSString stringWithFormat:@"%@://%@:%@%@",
                     self->scheme,
                     self->serviceName,
                     [NSNumber numberWithInt:self->port],
                     path];
}

@end
