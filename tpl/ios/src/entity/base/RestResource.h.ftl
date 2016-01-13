<@header?interpret />

#import <Foundation/Foundation.h>
#import "Resource.h"

@protocol RestResource <Resource>

@property (nonatomic, strong) NSString *localPath;

@end