//
//  ScannerView.m
//  QRCodeDemo
//
//  Created by Admin on 15/9/9.
//  Copyright (c) 2015年 yulei. All rights reserved.
//

#import "ScannerView.h"

@interface ScannerView ()
{
    //时间
    NSTimer *scannerTimer;
    //起始位置
    CGRect lineStartRect;
    //移动结束位置
    CGFloat lineMoveY;
    //移动位置
    CGRect lineMoveRect;
}

//提示
@property (strong, nonatomic) UILabel *tipLabel;
//扫描区域
@property (strong, nonatomic) UIImageView *scannerBg;
//扫描线
@property (strong, nonatomic) UIImageView *scannerLine;

@end

@implementation ScannerView

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

//绘制
- (void)drawRect:(CGRect)rect {

    CGContextRef ref = UIGraphicsGetCurrentContext();
    //设置背景区域颜色
    [self setBackgroundFillRect:ref];
    //设置透明区域
    [self setClearRect:ref];
    //设置白边
    [self setWhiteLineRect:ref];
    //设置四个边角
    [self setCornerLineRect:ref];
}

//设置背景区域颜色
- (void)setBackgroundFillRect:(CGContextRef)ref {
    CGContextSetRGBFillColor(ref, 40.0f/255.0f, 40.0f/255.0f, 40.0f/255.0f, 0.65f);
    CGContextFillRect(ref, self.bounds);
}

//设置透明区域
- (void)setClearRect:(CGContextRef)ref {
    CGContextClearRect(ref, self.clearDrawRect);
}

//设置白边
- (void)setWhiteLineRect:(CGContextRef)ref {
    CGContextStrokeRect(ref, self.clearDrawRect);
    CGContextSetRGBStrokeColor(ref, 1.0, 1.0, 1.0, 1.0);
    CGContextSetLineWidth(ref, 0.8);
    CGContextAddRect(ref, self.clearDrawRect);
    CGContextStrokePath(ref);
}

//设置四个边角
- (void)setCornerLineRect:(CGContextRef)ref {
    CGContextSetLineWidth(ref, 2.5);
    CGContextSetRGBStrokeColor(ref, 83.0/255.0, 239/255.0, 111/255.0, 1.0);//绿色
    
    //左上角
    CGPoint poinsTopLeftA[] = {
        CGPointMake(self.clearDrawRect.origin.x+0.5, self.clearDrawRect.origin.y),
        CGPointMake(self.clearDrawRect.origin.x+0.5, self.clearDrawRect.origin.y+15)
    };
    CGPoint poinsTopLeftB[] = {
        CGPointMake(self.clearDrawRect.origin.x, self.clearDrawRect.origin.y+0.5),
        CGPointMake(self.clearDrawRect.origin.x+15, self.clearDrawRect.origin.y+0.5)};
    CGContextAddLines(ref, poinsTopLeftA, 2);
    CGContextAddLines(ref, poinsTopLeftB, 2);
    
    //左下角
    CGPoint poinsBottomLeftA[] = {
        CGPointMake(self.clearDrawRect.origin.x+0.5, self.clearDrawRect.origin.y+self.clearDrawRect.size.height-15),
        CGPointMake(self.clearDrawRect.origin.x+0.5, self.clearDrawRect.origin.y+self.clearDrawRect.size.height)};
    CGPoint poinsBottomLeftB[] = {
        CGPointMake(self.clearDrawRect.origin.x, self.clearDrawRect.origin.y+self.clearDrawRect.size.height-0.5),
        CGPointMake(self.clearDrawRect.origin.x+15, self.clearDrawRect.origin.y+self.clearDrawRect.size.height-0.5)};
    CGContextAddLines(ref, poinsBottomLeftA, 2);
    CGContextAddLines(ref, poinsBottomLeftB, 2);
    
    //右上角
    CGPoint poinsTopRightA[] = {
        CGPointMake(self.clearDrawRect.origin.x+self.clearDrawRect.size.width-15, self.clearDrawRect.origin.y+0.5),
        CGPointMake(self.clearDrawRect.origin.x+self.clearDrawRect.size.width, self.clearDrawRect.origin.y+0.5)};
    CGPoint poinsTopRightB[] = {
        CGPointMake(self.clearDrawRect.origin.x+self.clearDrawRect.size.width-0.5, self.clearDrawRect.origin.y),
        CGPointMake(self.clearDrawRect.origin.x+self.clearDrawRect.size.width-0.5, self.clearDrawRect.origin.y+15)};
    CGContextAddLines(ref, poinsTopRightA, 2);
    CGContextAddLines(ref, poinsTopRightB, 2);
    
    //右下角
    CGPoint poinsBottomRightA[] = {
        CGPointMake(self.clearDrawRect.origin.x+self.clearDrawRect.size.width-0.5, self.clearDrawRect.origin.y+self.clearDrawRect.size.height-15),
        CGPointMake(self.clearDrawRect.origin.x+self.clearDrawRect.size.width-0.5, self.clearDrawRect.origin.y+self.clearDrawRect.size.height)};
    CGPoint poinsBottomRightB[] = {
        CGPointMake(self.clearDrawRect.origin.x+self.clearDrawRect.size.width-15, self.clearDrawRect.origin.y+self.clearDrawRect.size.height-0.5),
        CGPointMake(self.clearDrawRect.origin.x+self.clearDrawRect.size.width, self.clearDrawRect.origin.y+self.clearDrawRect.size.height-0.5)};
    CGContextAddLines(ref, poinsBottomRightA, 2);
    CGContextAddLines(ref, poinsBottomRightB, 2);
    CGContextStrokePath(ref);
}

#pragma mark - Main

//显示
- (void)show {
    //设置扫描背景
    //[self.scannerBg setFrame:self.clearDrawRect];
    //[self addSubview:self.scannerBg];
    
    CGFloat scannerLine_w = 220.0f;
    CGFloat scannerLine_h = 5.0f;
    CGFloat scannerLine_x = self.clearDrawRect.origin.x+(CGRectGetWidth(self.clearDrawRect)-scannerLine_w)/2;
    CGFloat scannerLine_y = self.clearDrawRect.origin.y+10.0f;
    lineStartRect = CGRectMake(scannerLine_x, scannerLine_y, scannerLine_w, scannerLine_h);
    lineMoveRect = lineStartRect;
    lineMoveY = scannerLine_y+CGRectGetHeight(self.clearDrawRect)-15.0f;
    
    //设置扫描线
    [self.scannerLine setFrame:lineStartRect];
    [self addSubview:self.scannerLine];
    [self.scannerLine setHidden:YES];
    
    //设置扫描提示
    CGFloat tipLabel_y = self.clearDrawRect.origin.y+CGRectGetHeight(self.clearDrawRect) + 15.0f;
    [self.tipLabel setFrame:CGRectMake(20.0f, tipLabel_y, CGRectGetWidth(self.bounds)-40.0f, 60.0f)];
    [self addSubview:self.tipLabel];
    
    //设置扫描时间
    scannerTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(scannerLineAnimation) userInfo:nil repeats:YES];
}

//扫描线动画
- (void)scannerLineAnimation {
    lineMoveRect.origin.y++;
    if (lineMoveRect.origin.y > lineMoveY) {
        lineMoveRect = lineStartRect;
    }
    [self.scannerLine setFrame:lineMoveRect];
}

//开始扫描
- (void)startScanner {
    _scannerLine.hidden = NO;
    [scannerTimer fire];
}

//结束扫描
- (void)stopScanner {
    if ([scannerTimer isValid]) {
        [scannerTimer invalidate];
    }
    _scannerLine.hidden = YES;
}

#pragma mark - Getter And Setter

- (UILabel *)tipLabel {
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.backgroundColor = [UIColor clearColor];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.numberOfLines = 2;
        _tipLabel.font = [UIFont systemFontOfSize:18.0f];
        _tipLabel.textColor = [UIColor whiteColor];
        _tipLabel.text = @"将二维码放入框内，即可自动扫描";
        //_tipLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _tipLabel;
}

- (UIImageView *)scannerBg {
    if (_scannerBg == nil) {
        _scannerBg = [[UIImageView alloc] init];
        _scannerBg.image = [UIImage imageNamed:@"scanner_bg"];
    }
    return _scannerBg;
}

- (UIImageView *)scannerLine {
    if (_scannerLine == nil) {
        _scannerLine = [[UIImageView alloc] init];
        _scannerLine.image = [UIImage imageNamed:@"scanner_line"];
    }
    return _scannerLine;
}

@end
