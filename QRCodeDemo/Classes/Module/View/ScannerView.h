//
//  ScannerView.h
//  QRCodeDemo
//  功能描述 - 透明扫描区域
//  Created by Admin on 15/9/9.
//  Copyright (c) 2015年 yulei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScannerView : UIView

//透明区域
@property (assign) CGRect clearDrawRect;

//展示
- (void)show;
//开始扫描
- (void)startScanner;
//结束扫描
- (void)stopScanner;

@end
