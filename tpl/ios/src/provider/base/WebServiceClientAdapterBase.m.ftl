<@header?interpret />

#import "WebServiceClientAdapterBase.h"

@implementation WebServiceClientAdapterBase

- (id) initWithServiceName:(NSString*) urlHost
                  withPort:(NSNumber*) urlPort
                withScheme:(NSString*) urlScheme
                  withPath:(NSString*) urlPath {
    return self;
}

- (void) invokeRequest:(Verb) verb
           withRequest:(NSString*) request
            withParams:(NSMutableDictionary*) params
          withCallback: (void(^)(NSObject*)) callback {
    
}

- (BOOL) isValidJSON:(NSObject *)json {
    return false;
}

- (BOOL) jsonHas:(NSDictionary*) json
    withProperty:(NSString*) property {
    
    BOOL result = false;
    
    result = [json objectForKey:property] != nil;
    
    return result;
}

- (BOOL) jsonIsNull:(NSDictionary*) json
       withProperty:(NSString*) property {
    
    BOOL result = ![self jsonHas: json withProperty: property]
            || [json objectForKey:property] == [NSNull null];
    
    return result;
}

- (BOOL) isOnline {
    // TODO check if network is available
    return true;
}

@end
