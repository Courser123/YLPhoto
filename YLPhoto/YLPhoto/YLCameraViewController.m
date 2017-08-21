//
//  YLCameraViewController.m
//  YLPhoto
//
//  Created by 王忠迪 on 20/08/2017.
//  Copyright © 2017 王忠迪. All rights reserved.
//

#import "YLCameraViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface YLCameraViewController ()

@property (nonatomic,strong) UIButton *returnBtn;
@property (nonatomic,strong) AVCaptureDevice *captureDevice;

@end

@implementation YLCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    // Do any additional setup after loading the view.
    [self setupUI];
    [self configCamera];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)setupUI {
    
    if ([UIDevice currentDevice].systemVersion.floatValue < 7.0) {
        [UIApplication sharedApplication].statusBarHidden = YES;
    }
    else if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        // iOS7及以上
        [self prefersStatusBarHidden];
        //这个是更新状态栏的显示状态,只支持iOS7及以上,使用performSelector是为了不影响主线程的其他工作
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    
    _returnBtn = [[UIButton alloc] init];
    [_returnBtn setBackgroundImage:[UIImage imageNamed:@"global_close"] forState:UIControlStateNormal];
    [_returnBtn addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_returnBtn];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)configCamera {
    
    AVCaptureSession * session = [[AVCaptureSession alloc] init];
    
    [session setSessionPreset:AVCaptureSessionPresetPhoto];
    
//    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice = [self cameraWithPosition:AVCaptureDevicePositionFront];
    
    self.captureDevice = captureDevice;
    //    if ([captureDevice lockForConfiguration:nil]) {
    //        [captureDevice setTorchMode:AVCaptureTorchModeOn];
    //    }
    
    
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil];
    
    if ([session canAddInput:deviceInput]) {
        [session addInput:deviceInput];
    }
    
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    CALayer *rootLayer = self.view.layer;
    
    [rootLayer setMasksToBounds:YES];
    
    previewLayer.frame = rootLayer.bounds;
    
    [rootLayer insertSublayer:previewLayer atIndex:0];
    
    [session startRunning];
    
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _returnBtn.frame = CGRectMake(15, 20, 30, 30);
}

- (void)dismissSelf {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"dealloc");
}

@end
