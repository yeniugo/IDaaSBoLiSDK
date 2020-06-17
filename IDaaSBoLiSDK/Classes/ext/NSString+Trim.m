//
//  NSString+Trim.m
//  UniformIdentityAuthentication
//
//  Created by Trusfort on 2016/12/25.
//  Copyright © 2016年 Trusfort. All rights reserved.
//

#import "NSString+Trim.h"

@implementation NSString (Trim)
- (NSString *)trim{
    
    if (self.length == 0) {
        return self;
    }
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}
- (NSString *)alltrim{
    if (self.length) {
        return self;
    }
    return [self stringByReplacingOccurrencesOfString:@" " withString:@""];
}
@end
