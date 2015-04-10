<@header?interpret />

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
#import "HttpResponse.h"

typedef enum
{
    GET,
    POST,
    PUT,
    DELETE,
    PATCH
} Verb;

@interface RestClientBase : NSObject {

@private
    NSString* serviceName;
    NSString* scheme;
    int port;
}

/** Open API key. */
+ (NSString*) API_KEY;
+ (NSString*) SCHEME_HTTP;

+ (void) setIsAuth:(BOOL) auth;

- (id) initWithServiceName:(NSString*) serviceName;

- (id) initWithServiceName:(NSString*) serviceName withPort:(int) port withScheme:(NSString*) scheme;

- (void) invoke:(Verb) verb
       withPath:(NSString*) path
 withJsonParams:(NSMutableDictionary*) jsonParams
   withCallback:(void(^)(HttpResponse*)) callback;

@end
