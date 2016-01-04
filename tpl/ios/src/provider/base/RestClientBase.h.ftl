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

@protected
    NSString* serviceName;
    NSString* scheme;
    int port;
}

/** API key. */
+ (NSString *) API_KEY;

/** SCHEME HTTP. */
+ (NSString *) SCHEME_HTTP;

/**
 * Set if is auth.
 * @param auth true or false
 */
+ (void) setIsAuth:(bool) auth;

/**
 * Init the Rest Client with service name.
 * @param serviceName The service name
 * @return the RestClient
 */
- (id) initWithServiceName:(NSString *) serviceName;

/**
 * Init the Rest Client with service name, port and scheme.
 * @param serviceName The service name
 * @param port The port
 * @param scheme The scheme
 * @return the RestClient
 */
- (id) initWithServiceName:(NSString *) serviceName withPort:(int) port withScheme:(NSString *) scheme;

/**
 * Invoke the request.
 * @param verb The Verb
 * @param path The Path
 * @param jsonParams The jsonParams
 * @param callback The HttpResponse
 */
- (void) invoke:(Verb) verb
       withPath:(NSString *) path
 withJsonParams:(NSMutableDictionary *) jsonParams
   withCallback:(void(^)(HttpResponse *)) callback;

@end
