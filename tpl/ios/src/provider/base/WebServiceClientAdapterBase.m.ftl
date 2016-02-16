<@header?interpret />

#import "WebServiceClientAdapterBase.h"
#import "Reachability.h"
#import "Config.h"

@implementation WebServiceClientAdapterBase

+ (NSString *) REST_FORMAT { return @".json"; }

-(instancetype) init {
    NSString *defaultHost = Config.REST_URL_HOST_PROD;
    NSString *defaultScheme = Config.URL_SCHEME_PROD;
    NSString *defaultPath = Config.URL_PATH_PROD;

#if DEBUG
    defaultHost = Config.REST_URL_HOST_DEV;
    defaultScheme = Config.URL_SCHEME_DEV;
    defaultPath = Config.URL_PATH_DEV;
#endif

    return [self initWithServiceName:defaultHost
                            withPort:[NSNumber numberWithInt:80]
                          withScheme:defaultScheme
                            withPath:defaultPath];
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
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];

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
