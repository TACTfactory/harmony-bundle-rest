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
    if (self.isOnline){
        NSString* url = [NSString stringWithFormat:@"%@://%@:%@",
                         self->scheme,
                         self->host,
                         self->port];
        
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:url]];
        
        if(verb == GET){
            [manager GET:[NSString stringWithFormat:@"%@/%@", url, request]
              parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  callback(responseObject);
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"Error: %@", error);
              }];
        }
    }
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
