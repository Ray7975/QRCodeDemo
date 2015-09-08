//
//  NSString+Expand.h
//  SeedSocial
//  功能描述 - NSString扩展
//  Created by Admin on 15/4/27.
//  Copyright (c) 2015年 altamob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Expand)

//计算字体size
- (CGSize)sizeWithFont:(UIFont *)font
           WithMaxSize:(CGSize)maxSize
       ByLineBreakMode:(NSLineBreakMode)lineBreakMode;

@end
