//
//  UILabel+Alignment.h
//  Good_IdentifyAuthentication
//
//  Created by hukai on 2019/7/19.
//  Copyright © 2019 zyc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (Alignment)
//两端对齐

- (void)textAlignmentLeftAndRight;

//指定Label以最后的冒号对齐的width两端对齐

- (void)textAlignmentLeftAndRightWith:(CGFloat)labelWidth;
@end

NS_ASSUME_NONNULL_END
