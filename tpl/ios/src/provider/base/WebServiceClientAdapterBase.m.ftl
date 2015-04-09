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
                  
	self->host = urlHost;
	self->port = urlPort;
	self->scheme = urlScheme;
	self->prefix = urlPath;
	
    return self;
}

- (void) invokeRequest:(Verb) verb
               withRequest:(NSString*) request
                withParams:(NSMutableDictionary*) params
              withCallback: (void(^)(NSObject*)) callback {
    if (self.isOnline) {
        RestClient *client = [[RestClient alloc] initWithServiceName:self->host withPort:[self->port intValue] withScheme:self->scheme];
        
        [client invoke:verb
                    withPath:[NSString stringWithFormat:@"%@%@", self->prefix, request]
              withJsonParams:params
                withCallback:callback];
    }
}

- (NSArray *) itemsToJson:(NSArray*) items {
    NSMutableArray *itemArray = [NSMutableArray new];
    
    for (int i = 0; i < [items count]; i++) {
        id jsonItem = [self itemToJson:items[i]];
        [itemArray addObject:jsonItem];
    }
    
    return itemArray;
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
