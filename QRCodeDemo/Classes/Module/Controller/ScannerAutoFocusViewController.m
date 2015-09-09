//
//  ScannerAutoFocusViewController.m
//  QRCodeDemo
//
//  Created by Admin on 15/9/9.
//  Copyright (c) 2015年 yulei. All rights reserved.
//

#import "ScannerAutoFocusViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ScannerAutoFocusViewController () <AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate>

//取消按钮
@property (strong, nonatomic) UIButton *button_cancel;
@property (strong, nonatomic) UIBarButtonItem *cancelButtonItem;

//管理输入输出流
@property (strong, nonatomic) AVCaptureSession *captureSession;
//显示捕获到的相机输出流
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
//
@property (strong, nonatomic) CALayer *targetLayer;
//检测对象列表
@property (strong, nonatomic) NSMutableArray *codeObjects;

@end

@implementation ScannerAutoFocusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"二维码自动对焦扫描"];
    [self layoutViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateScannerView];
}

#pragma mark - Main

- (void)layoutViews {
    [self.navigationItem setLeftBarButtonItem:self.cancelButtonItem];
}

//更新视图
- (void)updateScannerView {
    [self startScanner];
}

//是否授权
- (BOOL)isCaptureDeviceAuthorized {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus != AVAuthorizationStatusAuthorized) {
        return NO;
    }
    return YES;
}

//开始扫描
- (void)startScanner {
    self.codeObjects = nil;
    [self.captureSession startRunning];
}

//停止扫描
- (void)stopScanner {
    [self.captureSession stopRunning];
    self.captureSession = nil;
}

//清理绘制目标层
- (void)clearTargetLayer {
    NSArray *sublayers = [[self.targetLayer sublayers] copy];
    for (CALayer *sublayer in sublayers) {
        [sublayer removeFromSuperlayer];
    }
}

//显示检测对象
- (void)showDetectedObjects {
    for (AVMetadataObject *object in self.codeObjects) {
        if ([object isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            CAShapeLayer *shapeLayer = [CAShapeLayer layer];
            shapeLayer.strokeColor = [UIColor redColor].CGColor;
            shapeLayer.fillColor = [UIColor clearColor].CGColor;
            shapeLayer.lineWidth = 2.0f;
            shapeLayer.lineJoin = kCALineCapRound;
            CGPathRef path = [self createPathForPoints:[(AVMetadataMachineReadableCodeObject *)object corners]];
            shapeLayer.path = path;
            CFRelease(path);
            [self.targetLayer addSublayer:shapeLayer];
        }
    }
}

//绘制
- (CGMutablePathRef)createPathForPoints:(NSArray *)points {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPoint point;
    
    if ([points count] > 0) {
        CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)[points objectAtIndex:0], &point);
        CGPathMoveToPoint(path, nil, point.x, point.y);
        
        int i = 1;
        while (i < [points count]) {
            CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)[points objectAtIndex:i], &point);
            CGPathAddLineToPoint(path, nil, point.x, point.y);
            i++;
        }
        CGPathCloseSubpath(path);
    }
    
    return path;
}

//扫描报告
- (void)scannerReport:(NSString *)_result {
    [self stopScanner];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"扫描报告" message:_result delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self cancelButtonClick:self.button_cancel];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    NSLog(@"metadataObjects is %@",metadataObjects);
    self.codeObjects = nil;
    
    for (AVMetadataObject *metadataObject in metadataObjects) {
        AVMetadataObject *transformedObject = [self.previewLayer transformedMetadataObjectForMetadataObject:metadataObject];
        [self.codeObjects addObject:transformedObject];
    }
    
    [self clearTargetLayer];
    [self showDetectedObjects];
    
}

#pragma mark - UIResponse Event

//取消按钮点击事件
- (void)cancelButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - AVFoundation

- (NSMutableArray *)codeObjects {
    if (_codeObjects == nil) {
        _codeObjects = [NSMutableArray new];
    }
    return _codeObjects;
}

- (AVCaptureSession *)captureSession {
    if (_captureSession == nil) {
        NSError *error = nil;
        //物理捕获设备
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        //是否自持自动对焦范围
        if (device.isAutoFocusRangeRestrictionSupported) {
            if ([device lockForConfiguration:&error]) {
                [device setAutoFocusRangeRestriction:AVCaptureAutoFocusRangeRestrictionNear];
                [device unlockForConfiguration];
            }
        }

        //初始化输入流
        AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        if (deviceInput) {
            //创建会话
            _captureSession = [[AVCaptureSession alloc] init];
            //添加输入流
            if ([_captureSession canAddInput:deviceInput]) {
                [_captureSession addInput:deviceInput];
            }
            
            //初始化输入流
            AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
            //添加输出流
            if ([_captureSession canAddOutput:metadataOutput]) {
                [_captureSession addOutput:metadataOutput];
            }

            //设置队列
            [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
            //设置元数据类型
            [metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
            
            //创建输出对象
            self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
            [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
            [self.previewLayer setFrame:self.view.bounds];
            [self.view.layer addSublayer:self.previewLayer];
            //自动检测对焦层
            self.targetLayer = [CALayer layer];
            [self.targetLayer setFrame:self.view.bounds];
            [self.view.layer addSublayer:self.targetLayer];
        } else {
            NSLog(@"deviceInput error is %@",[error localizedDescription]);
        }
    }
    return _captureSession;
}

#pragma mark - Getter And Setter

- (UIButton *)button_cancel {
    if (_button_cancel == nil) {
        _button_cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60.0f, 44.0f)];
        [_button_cancel setBackgroundColor:[UIColor yellowColor]];
        [_button_cancel setTitle:@"Cancel" forState:UIControlStateNormal];
        [_button_cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_button_cancel addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button_cancel;
}

- (UIBarButtonItem *)cancelButtonItem {
    if (_cancelButtonItem == nil) {
        _cancelButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.button_cancel];
        _cancelButtonItem.style = UIBarButtonItemStyleDone;
    }
    return _cancelButtonItem;
}

@end
