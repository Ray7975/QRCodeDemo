//
//  MainViewController.m
//  TextKitDemo
//
//  Created by Admin on 15/9/1.
//  Copyright (c) 2015年 yulei. All rights reserved.
//

#import "MainViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ScannerViewController.h"
#import "ScannerAutoFocusViewController.h"

@interface MainViewController ()

//扫描按钮
@property (strong, nonatomic) UIButton *button_scanner;
//自动对焦扫描按钮
@property (strong, nonatomic) UIButton *button_scanner_autofocus;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self setTitle:@"二维码"];
    [self layoutViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Main

- (void)layoutViews {
    [self.button_scanner setFrame:CGRectMake(0, 0, 120.0f, 45.0f)];
    [self.button_scanner setCenter:CGPointMake(CGRectGetWidth(self.view.bounds)/2, CGRectGetHeight(self.view.bounds)/2-45.0f)];
    [self.view addSubview:self.button_scanner];
    
    [self.button_scanner_autofocus setFrame:CGRectMake(0, 0, 120.0f, 45.0f)];
    [self.button_scanner_autofocus setCenter:CGPointMake(CGRectGetWidth(self.view.bounds)/2, CGRectGetHeight(self.view.bounds)/2+45.0f)];
    [self.view addSubview:self.button_scanner_autofocus];
}

//是否授权
- (BOOL)isCaptureDeviceAuthorized {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus != AVAuthorizationStatusAuthorized) {
        return NO;
    }
    return YES;
}

//没有授权
- (void)captureDeviceAuthorizedError {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"友情提示" message:@"您没有权限访问摄像头" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - UIResponse Event

//扫描按钮点击事件
- (void)scannerButtonClick:(id)sender {
    if ([self isCaptureDeviceAuthorized]) {
        ScannerViewController *viewController = [[ScannerViewController alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        [self captureDeviceAuthorizedError];
    }
}

//自动对焦扫描按钮点击事件
- (void)scannerAutoFocusButtonClick:(id)sender {
    if ([self isCaptureDeviceAuthorized]) {
        ScannerAutoFocusViewController *viewController = [[ScannerAutoFocusViewController alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        [self captureDeviceAuthorizedError];
    }
}

#pragma mark - Getter And Setter

- (UIButton *)button_scanner {
    if (_button_scanner == nil) {
        _button_scanner = [[UIButton alloc] init];
        [_button_scanner setBackgroundColor:[UIColor yellowColor]];
        [_button_scanner setTitle:@"一般扫描" forState:UIControlStateNormal];
        [_button_scanner setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_button_scanner addTarget:self action:@selector(scannerButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button_scanner;
}

- (UIButton *)button_scanner_autofocus {
    if (_button_scanner_autofocus == nil) {
        _button_scanner_autofocus = [[UIButton alloc] init];
        [_button_scanner_autofocus setBackgroundColor:[UIColor yellowColor]];
        [_button_scanner_autofocus setTitle:@"自动对焦扫描" forState:UIControlStateNormal];
        [_button_scanner_autofocus setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_button_scanner_autofocus addTarget:self action:@selector(scannerAutoFocusButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button_scanner_autofocus;
}

@end
