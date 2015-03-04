<@header?interpret />

#import <Foundation/Foundation.h>
#import "RestClient.h"

@interface WebServiceClientAdapterBase : NSObject {
    @protected
    NSString* host;
    NSString* prefix;
    NSNumber* port;
    NSString* scheme;
}

- (id) initWithServiceName:(NSString*) urlHost
                  withPort:(NSNumber*) urlPort
                withScheme:(NSString*) urlScheme
                  withPath:(NSString*) urlPath;

- (void) invokeRequest:(Verb) verb
           withRequest:(NSString*) request
            withParams:(NSMutableDictionary*) params
          withCallback: (void(^)(NSObject*)) callback;

/**
 * Tests if the json is a valid Server Object.
 *
 * @param json The json
 *
 * @return True if valid
 */
- (BOOL) isValidJSON:(NSObject*) json;
    
- (BOOL) jsonHas:(NSDictionary*) json
    withProperty:(NSString*) property;

- (BOOL) jsonIsNull:(NSDictionary*) json
       withProperty:(NSString*) property;

- (BOOL) isOnline;

@end
