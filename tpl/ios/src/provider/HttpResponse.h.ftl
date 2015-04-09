<@header?interpret />

#import <Foundation/Foundation.h>

@interface HttpResponse : NSObject

@property (nonatomic) NSInteger statusCode;
@property (nonatomic, strong) NSDictionary *result;

@end