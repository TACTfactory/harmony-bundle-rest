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

/** REST FORMAT. */
+ (NSString *) REST_FORMAT;

/**
 * Init the Web Service Client Adapter.
 * @return WebServiceClientAdapterBase
 */
- (instancetype) init;

/**
 * Init the Web Service Client Adapter.
 * @param urlHost The Host url
 * @param urlPort The Port url
 * @param urlScheme The Scheme url
 * @param urlPath The Path url
 * @return the Web Service Client Adapter
 */
- (id) initWithServiceName:(NSString *) urlHost
                  withPort:(NSNumber *) urlPort
                withScheme:(NSString *) urlScheme
                  withPath:(NSString *) urlPath;

/**
 * Invoke the request.
 * @param verb The verb
 * @param request The request
 * @param params The params
 * @param callback The callback
 */
- (void) invokeRequest:(Verb) verb
           withRequest:(NSString *) request
            withParams:(NSMutableDictionary *) params
          withCallback: (void(^)(HttpResponse *)) callback;

/**
 * Get the uri.
 * @return the uri
 */
- (NSString *) getUri;

/**
 * Get the item id.
 * @param item The item
 * @return int Item id
 */
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
- (NSArray *) itemsIdToJson:(NSArray *) items;

/**
 * Convert a list of <entities> to a NSMutableDictionary.
 * @param users The array of <entities> to convert
 * @return The array of converted <entities>
 */
- (NSArray *) itemsToJson:(NSArray *) items;

/**
 * Extract a list of <T> from a JSONObject describing an array of <T> given the array name.
 * @param jsonArray The JSONArray
 * @param items The returned list of <T>
 * @return The number of <T> found in the JSON
 */
- (int) extractItems:(NSArray *) jsonArray
           withItems:(NSMutableArray *) items;

/**
 * Extract a list of <T> from a JSONObject describing an array of <T> given the array name.
 * @param json The JSONObject describing the array of <T>
 * @param items The returned list of <T>
 * @param paramName The name of the array
 * @return The number of <T> found in the JSON
 */
- (int) extractItems:(NSMutableDictionary *) json
       withParamName:(NSString *) paramName
           withItems:(NSMutableArray *) items;

/**
 * Extract a list of <T> from a JSONObject describing an array of <T> given the array name.
 * @param json The JSONObject describing the array of <T>
 * @param items The returned list of <T>
 * @param paramName The name of the array
 * @param limit Limit the number of items to parse
 * @return The number of <T> found in the JSON
 */
- (int) extractItems:(NSMutableDictionary *) json
       withParamName:(NSString *) paramName
           withItems:(NSMutableArray *) items
           withLimit:(int) limit;

/**
 * Extract the JSON in an item.
 * @param json The JSON
 * @param item The Item
 * @return true if extract success
 */
- (bool) extract:(NSMutableDictionary *) json
        withItem:(id) item;

/**
 * Tests if the json is a valid Server Object.
 * @param json The json
 * @return True if valid
 */
- (bool) isValidJSON:(NSObject *) json;

/**
 * Tests if the json has a property.
 * @param json The json
 * @param property The property
 * @return True if valid
 */
- (bool) jsonHas:(NSDictionary *) json
    withProperty:(NSString *) property;

/**
 * Tests if the json is null.
 * @param json The json
 * @param property The property
 * @return True if valid
 */
- (bool) jsonIsNull:(NSDictionary *) json
       withProperty:(NSString *) property;

/**
 * Tests if the web service is online.
 * @return True if online
 */
- (bool) isOnline;

@end
