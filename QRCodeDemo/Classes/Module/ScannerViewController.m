//
//  ScannerViewController.m
//  QRCodeDemo
//
//  Created by Admin on 15/9/9.
//  Copyright (c) 2015年 yulei. All rights reserved.
//

#import "ScannerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ScannerViewController () <AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate>
{
    //时间
    NSTimer *scannerTimer;
    //速度
    CGFloat scannerSpeed;
    //起始位置
    CGRect scannerStartFrame;
    //结束位置
    CGRect scannerEndFrame;
}

//取消按钮
@property (strong, nonatomic) UIButton *button_cancel;
@property (strong, nonatomic) UIBarButtonItem *cancelButtonItem;
//提示
@property (strong, nonatomic) UILabel *tipLabel;
//扫描区域
@property (strong, nonatomic) UIImageView *scannerBg;
//扫描线
@property (strong, nonatomic) UIImageView *scannerLine;

//管理输入输出流
@property (strong, nonatomic) AVCaptureSession *captureSession;
//显示捕获到的相机输出流
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation ScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"二维码扫描"];
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
    [self.view setBackgroundColor:[UIColor grayColor]];
    [self.navigationItem setLeftBarButtonItem:self.cancelButtonItem];
    
    [self.view addSubview:self.tipLabel];
    
    CGFloat scannerBg_x = (CGRectGetWidth(self.view.bounds)-280.0f)/2;
    CGFloat scannerBg_y = 180.0f;
    [self.scannerBg setFrame:CGRectMake(scannerBg_x, scannerBg_y, 280.0f, 280.0f)];
    [self.view addSubview:self.scannerBg];
    
    scannerStartFrame = CGRectMake(scannerBg_x+30.0f, scannerBg_y + 10.0f, 220.0f, 5.0f);
    scannerEndFrame = scannerStartFrame;
    scannerSpeed = 3.0f;
    [self.scannerLine setFrame:scannerStartFrame];
    [self.view addSubview:self.scannerLine];
    [self hideScannerLine];

    scannerTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(scannerLineAnimation) userInfo:nil repeats:YES];
}

//扫描线动画
- (void)scannerLineAnimation {
    scannerEndFrame.origin.y += scannerSpeed;
    if (scannerEndFrame.origin.y > (scannerStartFrame.origin.y + 260.0f)) {
        scannerEndFrame = scannerStartFrame;
    }
    [self.scannerLine setFrame:scannerEndFrame];
}

//显示扫描线
- (void)showScannerLine {
    _scannerLine.hidden = NO;
    [scannerTimer fire];
}

//隐藏扫描线
- (void)hideScannerLine {
    if ([scannerTimer isValid]) {
        [scannerTimer invalidate];
    }
    _scannerLine.hidden = YES;
}

//更新视图
- (void)updateScannerView {
    [self startScanner];
    [self showScannerLine];
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
    //self.codeObjects = nil;
    [self.captureSession startRunning];
}

//停止扫描
- (void)stopScanner {
    [self.captureSession stopRunning];
    self.captureSession = nil;
}


//扫描报告
- (void)scannerReport:(NSString *)_result {
    [self stopScanner];
    [self hideScannerLine];
    
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
            
            //设置扫描区域
            CGFloat interest_x = self.scannerBg.frame.origin.y/CGRectGetHeight(self.view.bounds);
            CGFloat interest_y = self.scannerBg.frame.origin.x/CGRectGetWidth(self.view.bounds);
            CGFloat interest_w = CGRectGetHeight(self.scannerBg.bounds)/CGRectGetHeight(self.view.bounds);
            CGFloat interest_h = CGRectGetWidth(self.scannerBg.bounds)/CGRectGetWidth(self.view.bounds);
            [metadataOutput setRectOfInterest:CGRectMake(interest_x, interest_y, interest_w, interest_h)];
            
            //设置队列
            [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
            //设置元数据类型
            [metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
            
            //创建输出对象
            self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
            [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
            [self.previewLayer setFrame:self.view.bounds];
            [self.view.layer insertSublayer:self.previewLayer atIndex:0];
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

- (UILabel *)tipLabel {
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 100.0f, CGRectGetWidth(self.view.bounds)-40.0f, 60.0f)];
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
