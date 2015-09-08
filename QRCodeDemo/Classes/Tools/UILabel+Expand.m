//
//  UILabel+Expand.m
//  SeedSocial
//
//  Created by Admin on 15/4/27.
//  Copyright (c) 2015年 altamob. All rights reserved.
//

#import "UILabel+Expand.h"

@implementation UILabel (Expand)

//计算文本尺寸
- (CGSize)contentSizeWithMaxSize:(CGSize)maxSize {
    NSMutableParagraphStyle *paragraphStype = [[NSMutableParagraphStyle alloc] init];
    [paragraphStype setLineBreakMode:self.lineBreakMode];
    [paragraphStype setAlignment:self.textAlignment];
    
    NSDictionary *contentDict = @{NSFontAttributeName : self.font,
                                  NSParagraphStyleAttributeName : paragraphStype};
    return [self.text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:contentDict context:nil].size;
}

//计算富文本尺寸
- (CGRect)attributedContentSizeWithMaxSize:(CGSize)maxSize {
    return [self.attributedText boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil];
}

@end
