<@header?interpret />

#import "RestClient.h"

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

typedef enum
{
    GET,
    POST,
    PUT,
    DELETE
} Verb;

@interface RestClient : NSObject {

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
   withCallback:(void(^)(NSObject*)) callback;

@end
