//
//  ScannerViewController.m
//  QRCodeDemo
//
//  Created by Admin on 15/9/9.
//  Copyright (c) 2015年 yulei. All rights reserved.
//

#import "ScannerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ScannerView.h"

@interface ScannerViewController () <AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate>

//取消按钮
@property (strong, nonatomic) UIButton *button_cancel;
@property (strong, nonatomic) UIBarButtonItem *cancelButtonItem;
//扫描区域
@property (strong, nonatomic) ScannerView *scannerView;

//管理输入输出流
@property (strong, nonatomic) AVCaptureSession *captureSession;
//显示捕获到的相机输出流
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation ScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"二维码扫描"];
    [self.navigationItem setLeftBarButtonItem:self.cancelButtonItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self startScanner];
}

#pragma mark - Main

//开始扫描
- (void)startScanner {
    [self.captureSession startRunning];
    //扫描线开始移动
    [self.scannerView startScanner];
}

//停止扫描
- (void)stopScanner {
    [self.captureSession stopRunning];
    self.captureSession = nil;
    //扫描线停止移动
    [self.scannerView stopScanner];
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
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *machineReadableCodeObject = [metadataObjects objectAtIndex:0];
        if ([[machineReadableCodeObject type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self scannerReport:machineReadableCodeObject.stringValue];
            });
        } else {
            NSLog(@"未识别");
        }
    }
}

#pragma mark - UIResponse Event

//取消按钮点击事件
- (void)cancelButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - AVFoundation

- (AVCaptureSession *)captureSession {
    if (_captureSession == nil) {
        NSError *error = nil;
        //物理捕获设备
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
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
            
            //创建输出对象
            self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
            [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
            [self.previewLayer setFrame:self.view.bounds];
            [self.view.layer insertSublayer:self.previewLayer atIndex:0];
            
            //创建扫描区域
            CGFloat clearDrawRect_w = 260.0f;
            CGFloat clearDrawRect_h = 260.0f;
            CGFloat clearDrawRect_x = (CGRectGetWidth(self.view.bounds) - clearDrawRect_w)/2;
            CGFloat clearDrawRect_y = (CGRectGetHeight(self.view.bounds) - clearDrawRect_h)/2;
            CGRect clearDrawRect = CGRectMake(clearDrawRect_x, clearDrawRect_y, clearDrawRect_w, clearDrawRect_h);
            
            self.scannerView = [[ScannerView alloc] init];
            [self.scannerView setFrame:self.view.bounds];
            [self.scannerView setBackgroundColor:[UIColor clearColor]];
            [self.scannerView setClearDrawRect:clearDrawRect];
            [self.scannerView show];
            [self.view addSubview:self.scannerView];
            
            //设置扫描区域
            CGFloat interest_x = clearDrawRect_y/CGRectGetHeight(self.view.bounds);
            CGFloat interest_y = clearDrawRect_x/CGRectGetWidth(self.view.bounds);
            CGFloat interest_w = clearDrawRect_h/CGRectGetHeight(self.view.bounds);
            CGFloat interest_h = clearDrawRect_w/CGRectGetWidth(self.view.bounds);
            [metadataOutput setRectOfInterest:CGRectMake(interest_x, interest_y, interest_w, interest_h)];
            
            //设置队列
            [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
            //设置元数据类型
            [metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
            //增加条形码扫描
            //metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeEAN13Code,
            //                                       AVMetadataObjectTypeEAN8Code,
            //                                       AVMetadataObjectTypeCode128Code,
            //                                       AVMetadataObjectTypeQRCode];
            
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
