<@header?interpret />

#import "WebServiceClientAdapterBase.h"
#import "Reachability.h"

@implementation WebServiceClientAdapterBase

+ (NSString *) REST_FORMAT { return @".json"; }

-(instancetype) init {
    return [self initWithServiceName:@""
                            withPort:[NSNumber numberWithInt:80]
                          withScheme:@"http"
                            withPath:@""];
}

- (NSDictionary *) httpResponse:(NSInteger) statusCode {
    NSDictionary *result = [NSDictionary new];

    return result;
}

- (id) initWithServiceName:(NSString *) urlHost
                  withPort:(NSNumber *) urlPort
                withScheme:(NSString *) urlScheme
                  withPath:(NSString *) urlPath {

    self->host = urlHost;
    self->port = urlPort;
    self->scheme = urlScheme;
    self->prefix = urlPath;

    return self;
}

- (void) invokeRequest:(Verb) verb
           withRequest:(NSString *) request
            withParams:(NSMutableDictionary *) params
          withCallback: (void(^)(HttpResponse *)) callback {
    if (self.isOnline) {
        RestClient *client = [[RestClient alloc] initWithServiceName:self->host
                                                            withPort:[self->port intValue]
                                                          withScheme:self->scheme];

        [client invoke:verb
              withPath:[NSString stringWithFormat:@"%@%@", self->prefix, request]
        withJsonParams:params
          withCallback:callback];
    }
}

- (NSArray *) itemsToJson:(NSArray *) items {
    NSMutableArray *itemArray = [NSMutableArray new];

    for (int i = 0; i < [items count]; i++) {
        id jsonItem = [self itemToJson:items[i]];
        [itemArray addObject:jsonItem];
    }

    return itemArray;
}

- (bool) isValidJSON:(NSObject *) json {
    return true;
}

- (bool) jsonHas:(NSDictionary *) json
    withProperty:(NSString *) property {

    bool result = false;

    result = [json objectForKey:property] != nil;

    return result;
}

- (bool) jsonIsNull:(NSDictionary *) json
       withProperty:(NSString *) property {

    bool result = ![self jsonHas:json withProperty:property] || [json objectForKey:property] == [NSNull null];

    return result;
}

- (bool) isOnline {
    bool result = false;

    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachibilityStatus];

    if (networkStatus != NotReachable) {
        result = true;
    }

    return result;
}

- (int) getItemId:(id) item {
    //TODO get item id
    return 0;
}

- (NSString *) getUri {
    //TODO get URI
    return nil;
}

- (NSArray *) itemsIdToJson:(NSArray*) item {
    //TODO
    return nil;
}

- (int) extractItems:(NSArray*) jsonArray
           withItems:(NSMutableArray*) items {
    //TODO
    return 0;
}

- (NSMutableDictionary *) itemToJson:(id) item {
    return [NSMutableDictionary new];
}

- (bool) extract:(NSMutableDictionary *)json
        withItem:(id)item {
    return false;
}

- (int) extractItems:(NSMutableDictionary *) json
       withParamName:(NSString *) paramName
           withItems:(NSMutableArray *) items {
    return 0;
}

- (int) extractItems:(NSMutableDictionary *) json
       withParamName:(NSString *) paramName
           withItems:(NSMutableArray *) items
           withLimit:(int) limit {
    return 0;
}

@end
