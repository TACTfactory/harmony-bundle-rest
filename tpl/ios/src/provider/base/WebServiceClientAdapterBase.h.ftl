<@header?interpret />

#import <Foundation/Foundation.h>
#import "RestClient.h"

@interface WebServiceClientAdapterBase : NSObject {
    @protected
    NSString* host;
    NSString* prefix;
    NSNumber* port;
    NSString* scheme;

    @public
    NSInteger statusCode;
}

+ (NSString *) REST_FORMAT;

- (instancetype) init;

- (id) initWithServiceName:(NSString*) urlHost
                  withPort:(NSNumber*) urlPort
                withScheme:(NSString*) urlScheme
                  withPath:(NSString*) urlPath;

- (void) invokeRequest:(Verb) verb
           withRequest:(NSString*) request
            withParams:(NSMutableDictionary*) params
          withCallback: (void(^)(HttpResponse*)) callback;

- (NSString *) getUri;

- (int) getItemId:(id) item;

/**
 * Convert an item to a JSONObject.
 * @param item The item to convert
 * @return The converted item
 */
- (NSMutableDictionary *) itemToJson:(id) item;

/**
 * Convert a list of <entities> to a NSMutableDictionary.
 * @param users The array of <entities> to convert
 * @return The array of converted <entities>
 */
- (NSArray *) itemsIdToJson:(NSArray*) items;

/**
 * Convert a list of <entities> to a NSMutableDictionary.
 * @param users The array of <entities> to convert
 * @return The array of converted <entities>
 */
- (NSArray *) itemsToJson:(NSArray*) items;

- (int) extractItems:(NSArray*) jsonArray
           withItems:(NSMutableArray*) items;

- (BOOL) extract:(NSMutableDictionary *)json
        withItem:(id)item;

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
