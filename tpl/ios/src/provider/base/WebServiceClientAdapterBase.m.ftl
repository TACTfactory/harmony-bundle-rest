<@header?interpret />

#import "WebServiceClientAdapterBase.h"

@implementation WebServiceClientAdapterBase

+ (NSString *) REST_FORMAT { return @".json"; }

-(instancetype) init {
	return [self initWithServiceName:@""
				withPort:[NSNumber numberWithInt: 80]
				withScheme:@"http"
				withPath:@""];
}

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
        manager.requestSerializer = [AFJSONRequestSerializer serializer];

        if(verb == GET) {
            [manager GET:[NSString stringWithFormat:@"%@/%@", url, request]
              parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  callback(responseObject);
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"Error: %@", error);
              }];
        } else if (verb == POST) {
            [manager POST:[NSString stringWithFormat:@"%@/%@", url, request]
              parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  callback(responseObject);
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"Error: %@", error);
              }];
        } else if (verb == DELETE) {
            [manager DELETE:[NSString stringWithFormat:@"%@/%@", url, request]
              parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  callback(responseObject);
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"Error: %@", error);
              }];
        } else if (verb == PUT) {
            [manager PUT:[NSString stringWithFormat:@"%@/%@", url, request]
              parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  callback(responseObject);
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"Error: %@", error);
              }];
        } else if (verb == PATCH) {
            [manager PATCH:[NSString stringWithFormat:@"%@/%@", url, request]
              parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  callback(responseObject);
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"Error: %@", error);
              }];
        }
    }
}

- (BOOL) isValidJSON:(NSObject *)json {
    return true;
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
