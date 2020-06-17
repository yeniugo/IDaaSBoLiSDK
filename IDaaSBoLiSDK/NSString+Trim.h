//
//  NSString+Trim.h
//  UniformIdentityAuthentication
//
//  Created by Trusfort on 2016/12/25.
//  Copyright © 2016年 Trusfort. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Trim)
//- (NSString *)trim;
/** trim */
@property (nonatomic, copy, readonly) NSString *trim;
@property (nonatomic, copy, readonly) NSString *alltrim;
@end
