//
//  NSString+Expand.m
//  SeedSocial
//
//  Created by Admin on 15/4/27.
//  Copyright (c) 2015年 altamob. All rights reserved.
//

#import "NSString+Expand.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Expand)

//计算字体size
- (CGSize)sizeWithFont:(UIFont *)font
           WithMaxSize:(CGSize)maxSize
       ByLineBreakMode:(NSLineBreakMode)lineBreakMode
{
    NSMutableParagraphStyle *paragraphStype = [[NSMutableParagraphStyle alloc] init];
    [paragraphStype setLineBreakMode:lineBreakMode];
    
    NSDictionary *contentDict = @{NSFontAttributeName : font,
                                  NSParagraphStyleAttributeName : paragraphStype};
    CGSize size = [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:contentDict context:nil].size;
    return size;
}

@end
