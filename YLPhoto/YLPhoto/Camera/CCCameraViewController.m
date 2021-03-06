//
//  CCCameraViewController.m
//  CCCamera
//
//  Created by wsk on 16/8/22.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "CCCameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <CoreMedia/CMMetadata.h>

#import "CCImagePreviewController.h"
#import "CCCameraView.h"

#import "CCMotionManager.h"
#import "UIView+CCHUD.h"

#import <GPUImage.h>
#import "GPUImageBeautifyFilter.h"
#import "UIImage+fixOrientation.h"
#import <TZImagePickerController.h>
#import <CoreMotion/CoreMotion.h>
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"
#import "CCImagePreviewView.h"

#import <MediaPlayer/MediaPlayer.h>

#define ISIOS9 __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0

@interface CCCameraViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate,CCCameraViewDelegate,TZImagePickerControllerDelegate,CCImagePreviewControllerDelegate>
{
    AVCaptureSession          *_captureSession;
    
    // 输入
    AVCaptureDeviceInput      *_deviceInput;
        
    // 输出
    AVCaptureConnection       *_videoConnection;
    AVCaptureConnection       *_audioConnection;
    AVCaptureVideoDataOutput  *_videoOutput;
    AVCaptureStillImageOutput *_imageOutput;
    
    // 文件
    NSURL				      *_movieURL;
    AVAssetWriter             *_assetWriter;
    AVAssetWriterInput	      *_assetAudioInput;
    AVAssetWriterInput        *_assetVideoInput;
    
    dispatch_queue_t           _movieWritingQueue;
    BOOL					   _readyToRecordVideo;
    BOOL					   _readyToRecordAudio;
    BOOL                       _recording;
    AVCaptureFlashMode         _currentflashMode; // 当前闪光灯的模式
    BOOL                       isIntoBg;
    UISlider                   *volumeViewSlider;
    NSDate                     *_lastLongPressDate;
}

@property(nonatomic, strong) CCCameraView *cameraView;
@property(nonatomic, strong) CCMotionManager *motionManager;
@property(nonatomic,strong)  CMMotionManager *cmmotionManager;
@property(nonatomic, strong) AVCaptureDevice *activeCamera;     // 当前输入设备
@property(nonatomic, strong) AVCaptureDevice *inactiveCamera;   // 不活跃的设备(这里指前摄像头或后摄像头，不包括外接输入设备)
@property(nonatomic, assign) AVCaptureVideoOrientation	referenceOrientation; // 视频播放方向

@property (nonatomic , strong) GPUImageFilterGroup *filter;
//@property (nonatomic , strong) GPUImageFilter *filter;
@property (nonatomic , strong) GPUImageVideoCamera *mGPUVideoCamera;
@property (nonatomic , weak)   GPUImageView *mView;
@property (nonatomic , strong) GPUImagePicture *stillImageSource;

@property (nonatomic , strong) GPUImageBilateralFilter *bilateralFilter;
@property (nonatomic , strong) GPUImageBrightnessFilter *brightnessFilter;

@property (nonatomic , weak)   UIImageView *backImageView;
@property (nonatomic ,  weak)   UIButton *flashBtn;
@property (nonatomic ,  strong) CCImagePreviewView *previewView;
@property (nonatomic ,  assign) CMSampleBufferRef sampleBuffer;

@property (nonatomic , strong)  MPVolumeView *volumeView;
@property (nonatomic, assign) CGFloat volume;

@end

@implementation CCCameraViewController

#pragma mark - life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self hideStatusBar];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _movieURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"movie.mov"]];
    _referenceOrientation = AVCaptureVideoOrientationPortrait;
    _motionManager = [[CCMotionManager alloc] init];
    
    self.cmmotionManager = [[CMMotionManager alloc] init];

    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.backImageView = backImageView;
    backImageView.hidden = YES;
    backImageView.image = [UIImage imageNamed:@"timg1.jpg"];
    [self.view addSubview:backImageView];
    
    self.cameraView = [[CCCameraView alloc] initWithFrame:self.view.bounds];
    self.cameraView.backgroundColor = [UIColor clearColor];
    self.cameraView.delegate = self;
    [self.view addSubview:self.cameraView];
    
    NSError *error;
    [self setupSession:&error position:AVCaptureDevicePositionBack];
    if (!error) {
//        [self.cameraView.previewView setCaptureSessionsion:_captureSession];

//        GPUImageFilter *filter;
        GPUImageFilterGroup *filter;
        
//        filter = [[GPUImageFilter alloc] init];
        //    filter = [[GPUImageSepiaFilter alloc] init]; // 褐色(怀旧)
//            filter = [[GPUImageAverageLuminanceThresholdFilter alloc] init]; // 图像黑白,类似漫画效果
//            filter = [[GPUImageSobelEdgeDetectionFilter alloc] init]; //Sobel边缘检测算法(白边，黑内容，有点漫画的反色效果)
//            filter = [[GPUImageCannyEdgeDetectionFilter alloc] init]; // Canny边缘检测算法（比上更强烈的黑白对比度）
//            filter = [[GPUImageSketchFilter alloc] init]; //素描
        
//            filter = [[GPUImageToonFilter alloc] init]; //卡通效果（黑色粗线描边）
//            filter = [[GPUImageSmoothToonFilter alloc] init]; //相比上面的效果更细腻，上面是粗旷的画风
        
        //    GPUImageBulgeDistortionFilter *filter = [[GPUImageBulgeDistortionFilter alloc] init];
        //    filter.radius = 0.75; //凸起失真，鱼眼效果
        //    filter = [[GPUImagePinchDistortionFilter alloc] init]; //收缩失真，凹面镜
        //    filter = [[GPUImageStretchDistortionFilter alloc] init]; //伸展失真，哈哈镜
//            filter = [[GPUImageGlassSphereFilter alloc] init]; //水晶球效果
//        filter = [[GPUImageEmbossFilter alloc] init]; //浮雕效果，带有点3d的感觉
        filter = [[GPUImageBeautifyFilter alloc] init]; // 美颜效果
        
        GPUImageView *mView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
        mView.backgroundColor = [UIColor clearColor];
        self.mView = mView;
        
//        [self.mGPUVideoCamera addTarget:filter];
//        [filter addTarget:mView];

        [self.mGPUVideoCamera addTarget:mView];
        
        [self.view addSubview:mView];
        [self.view sendSubviewToBack:mView];
        self.filter = filter;
        
        [self startCaptureSession];
    }
    else{
        [self showError:error];
    }
    
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    
    //进入后台
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(intoBackg) name:UIApplicationDidBecomeActiveNotification object:nil];
    //进入前台
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(returnBackg) name:UIApplicationWillResignActiveNotification object:nil];
    
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
    volumeView.hidden = NO;
    volumeView.center = CGPointMake(-550,370);//设置中心点，让音量视图不显示在屏幕中
    [volumeView sizeToFit];
    [volumeView userActivity];
    [self.view addSubview:volumeView];
    
    volumeViewSlider = [[UISlider alloc] init];
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeViewSlider = (UISlider *)view;
            break;
        }
    }
    
    self.volume = [[AVAudioSession sharedInstance] outputVolume];
    
    _lastLongPressDate = [NSDate date];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
//    AudioSessionSetActive(true);
    self.volume = [[AVAudioSession sharedInstance] outputVolume];
     isIntoBg = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
//    AudioSessionSetActive(false);
     isIntoBg = YES;
}

- (void)dealloc{
    NSLog(@"相机界面销毁了");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

#pragma mark - 输入设备(摄像头)
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

- (AVCaptureDevice *)activeCamera
{
//    return _deviceInput.device;
    return self.mGPUVideoCamera.inputCamera;
}

- (AVCaptureDevice *)inactiveCamera
{
    AVCaptureDevice *device = nil;
    if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1) {
        if ([self activeCamera].position == AVCaptureDevicePositionBack) {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        }
        else{
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}

#pragma mark - AVCaptureSession
// 配置会话
- (void)setupSession:(NSError **)error position:(AVCaptureDevicePosition)positon
{
    self.mGPUVideoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:positon];
    self.mGPUVideoCamera.outputImageOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (self.mGPUVideoCamera.inputCamera.position == AVCaptureDevicePositionFront) {
        self.mGPUVideoCamera.horizontallyMirrorFrontFacingCamera = YES;
    }else {
        self.mGPUVideoCamera.horizontallyMirrorFrontFacingCamera = NO;
    }
    
//    _captureSession = [[AVCaptureSession alloc]init];
    _captureSession = self.mGPUVideoCamera.captureSession;
//    [_captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    
    [self setupSessionInputs:error];
    [self setupSessionOutputs:error];
}

// 添加输入
- (void)setupSessionInputs:(NSError **)error
{
    // 视频输入
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:error];
    if (videoInput) {
        if ([_captureSession canAddInput:videoInput]){
            [_captureSession addInput:videoInput];
            _deviceInput = videoInput;
        }
    }
    
    // 音频输入
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioIn = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:error];
    if ([_captureSession canAddInput:audioIn]){
        [_captureSession addInput:audioIn];
    }
}

// 添加输出
- (void)setupSessionOutputs:(NSError **)error
{
    dispatch_queue_t captureQueue = dispatch_queue_create("com.cc.MovieCaptureQueue", DISPATCH_QUEUE_SERIAL);
    
    // 视频输出
    AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc] init];
    [videoOut setAlwaysDiscardsLateVideoFrames:YES];
    [videoOut setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]}];
    [videoOut setSampleBufferDelegate:self queue:captureQueue];
    if ([_captureSession canAddOutput:videoOut]){
        [_captureSession addOutput:videoOut];
        _videoOutput = videoOut;
    }
    _videoConnection = [videoOut connectionWithMediaType:AVMediaTypeVideo];
    _videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    // 音频输出
    AVCaptureAudioDataOutput *audioOut = [[AVCaptureAudioDataOutput alloc] init];
    [audioOut setSampleBufferDelegate:self queue:captureQueue];
    if ([_captureSession canAddOutput:audioOut]){
        [_captureSession addOutput:audioOut];
    }
    _audioConnection = [audioOut connectionWithMediaType:AVMediaTypeAudio];
    
    // 静态图片输出
    AVCaptureStillImageOutput *imageOutput = [[AVCaptureStillImageOutput alloc] init];            
    imageOutput.outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    if ([_captureSession canAddOutput:imageOutput]) {
        [_captureSession addOutput:imageOutput];
        _imageOutput = imageOutput;
    }
}

// 开启捕捉
- (void)startCaptureSession
{
    if (!_movieWritingQueue) {
        _movieWritingQueue = dispatch_queue_create("Movie Writing Queue", DISPATCH_QUEUE_SERIAL);
    }
    if (!_captureSession.isRunning){
        [_captureSession startRunning];
    }
}

// 停止捕捉
- (void)stopCaptureSession
{
    if (_captureSession.isRunning){
        [_captureSession stopRunning];
    }
}

#pragma mark - 拍摄照片
-(void)takePictureImage:(UIDeviceOrientation)orientationNew{
    
//    self.mView.hidden = YES;
//    self.backImageView.hidden = NO;
//    self.cameraView.hidden = YES;
//    self.mView.crRotation = kGPUImageRotateRight;
    
    AVCaptureConnection *connection = [_imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (self.mGPUVideoCamera.inputCamera.position == AVCaptureDevicePositionFront) {
        connection.videoMirrored = YES;
    }else {
        connection.videoMirrored = NO;
    }
    //    if (connection.isVideoOrientationSupported) {
    //        connection.videoOrientation = [self currentVideoOrientation];
    //    }
    //    connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    id takePictureSuccess = ^(CMSampleBufferRef sampleBuffer,NSError *error){
        if (sampleBuffer == NULL) {
            [self showError:error];
            return ;
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
//        [_captureSession stopRunning];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            UIImage *currentFilteredVideoFrame;
            currentFilteredVideoFrame = image;
//            if (!self.mGPUVideoCamera.horizontallyMirrorFrontFacingCamera) {
//                currentFilteredVideoFrame = image;
//            }else {
//                currentFilteredVideoFrame = [self.filter imageByFilteringImage:image];
//            }
            //        CCImagePreviewController *vc = [[CCImagePreviewController alloc] initWithImage:currentFilteredVideoFrame frame:self.cameraView.previewView.frame imgOrientation:orientationNew];
            //        vc.delegate = self;
            //        [self presentViewController:vc animated:YES completion:^{
            //
            //        }];
            dispatch_async(dispatch_get_main_queue(), ^{
                CCImagePreviewView *previewView =[[CCImagePreviewView alloc] initWithImage:currentFilteredVideoFrame frame:self.view.bounds imgOrientation:orientationNew];
                previewView.originImage = image;
                previewView.alpha = 0;
                __weak CCImagePreviewView *weakView = previewView;
                previewView.presentFilterViewController = ^(FWBeautyViewController *fw) {
                    [self presentViewController:fw animated:YES completion:^{
                        [weakView removeFromSuperview];
                    }];
                };
                [self.view addSubview:previewView];
//                [_captureSession startRunning];
                [UIView animateWithDuration:0.25 animations:^{
                    previewView.alpha = 1;
                } completion:^(BOOL finished) {
                    
                }];
            });
            //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //            [self presentViewController:vc animated:NO completion:^{
            //                self.mView.hidden = NO;
            //                self.backImageView.hidden = YES;
            //                self.cameraView.hidden = NO;
            //            }];
            //        });
        });

    };
    [_imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:takePictureSuccess];
    
}

#pragma mark - 录制视频
// 开始录制
- (void)startRecording
{
    // 删除原来的视频文件
    [self removeFile:_movieURL];
    dispatch_async(_movieWritingQueue, ^{
        if (!_assetWriter) {
            NSError *error;
            _assetWriter = [[AVAssetWriter alloc] initWithURL:_movieURL fileType:AVFileTypeQuickTimeMovie error:&error];
            !error?:[self showError:error];
        }
        _recording = YES;
    });
}

// 停止录制
- (void)stopRecording
{
    _recording = NO;
    if (![self inputsReadyToRecord]) {
        [self.view showAlertView:self message:@"录制视频出错了" sure:nil cancel:nil];
        return ;
    }
    
    dispatch_async(_movieWritingQueue, ^{
        [_assetWriter finishWritingWithCompletionHandler:^(){
            BOOL isSave = NO;// 是否生成完整的视频
            switch (_assetWriter.status)
            {
                case AVAssetWriterStatusCompleted:
                {
                    _readyToRecordVideo = NO;
                    _readyToRecordAudio = NO;
                    _assetWriter = nil;
                    isSave = YES;
                    break;
                }
                case AVAssetWriterStatusFailed:
                {
                    isSave = NO;
                    [self showError:_assetWriter.error];
                    break;
                }
                default:
                    break;
            }
            if (isSave) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.view showAlertView:self message:@"是否保存到相册" sure:^(UIAlertAction *act) {
                        [self saveMovieToCameraRoll];
                    } cancel:nil];
                });
            }
        }];
    });
}

// 保存视频
- (void)saveMovieToCameraRoll
{
    [self.view showLoadHUD:self message:@"保存中..."];
    if (ISIOS9) {
        [PHPhotoLibrary requestAuthorization:^( PHAuthorizationStatus status ) {
            if (status != PHAuthorizationStatusAuthorized) return ;
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetCreationRequest *videoRequest = [PHAssetCreationRequest creationRequestForAsset];
                [videoRequest addResourceWithType:PHAssetResourceTypeVideo fileURL:_movieURL options:nil];
            } completionHandler:^( BOOL success, NSError * _Nullable error ) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.view hideHUD];
                });
                success?:[self showError:error];
            }];
        }];
    }
    else{
        ALAssetsLibrary *lab = [[ALAssetsLibrary alloc]init];
        [lab writeVideoAtPathToSavedPhotosAlbum:_movieURL completionBlock:^(NSURL *assetURL, NSError *error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.view hideHUD];
            });
            !error?:[self showError:error];
        }];
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (_recording) {
        CFRetain(sampleBuffer);
        dispatch_async(_movieWritingQueue, ^{
            if (_assetWriter)
            {
                if (connection == _videoConnection)
                {
                    if (!_readyToRecordVideo){
                        _readyToRecordVideo = [self setupAssetWriterVideoInput:CMSampleBufferGetFormatDescription(sampleBuffer)];
                    }
                    
                    if ([self inputsReadyToRecord]){
                        [self writeSampleBuffer:sampleBuffer ofType:AVMediaTypeVideo];
                    }
                }
                else if (connection == _audioConnection){
                    if (!_readyToRecordAudio){
                        _readyToRecordAudio = [self setupAssetWriterAudioInput:CMSampleBufferGetFormatDescription(sampleBuffer)];
                    }
                    
                    if ([self inputsReadyToRecord]){
                        [self writeSampleBuffer:sampleBuffer ofType:AVMediaTypeAudio];
                    }
                }
            }
            CFRelease(sampleBuffer);
        });
    }
}

- (BOOL)inputsReadyToRecord{
    return _readyToRecordVideo && _readyToRecordAudio;
}

- (void)writeSampleBuffer:(CMSampleBufferRef)sampleBuffer ofType:(NSString *)mediaType
{
    if (_assetWriter.status == AVAssetWriterStatusUnknown)
    {
        if ([_assetWriter startWriting]){
            [_assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
        }
        else{
            [self showError:_assetWriter.error];
        }
    }
    
    if (_assetWriter.status == AVAssetWriterStatusWriting)
    {
        if (mediaType == AVMediaTypeVideo)
        {
            if (!_assetVideoInput.readyForMoreMediaData){
                return;
            }
            if (![_assetVideoInput appendSampleBuffer:sampleBuffer]){
                [self showError:_assetWriter.error];
            }
        }
        else if (mediaType == AVMediaTypeAudio){
            if (!_assetAudioInput.readyForMoreMediaData){
                return;
            }
            if (![_assetAudioInput appendSampleBuffer:sampleBuffer]){
                [self showError:_assetWriter.error];
            }
        }
    }
}

#pragma mark - configer
// 配置音频源数据写入
- (BOOL)setupAssetWriterAudioInput:(CMFormatDescriptionRef)currentFormatDescription
{
    size_t aclSize = 0;
    const AudioStreamBasicDescription *currentASBD = CMAudioFormatDescriptionGetStreamBasicDescription(currentFormatDescription);
    const AudioChannelLayout *currentChannelLayout = CMAudioFormatDescriptionGetChannelLayout(currentFormatDescription, &aclSize);
    
    NSData *currentChannelLayoutData = nil;
    if (currentChannelLayout && aclSize > 0 ){
        currentChannelLayoutData = [NSData dataWithBytes:currentChannelLayout length:aclSize];
    }
    else{
        currentChannelLayoutData = [NSData data];
    }
    NSDictionary *audioCompressionSettings = @{AVFormatIDKey:[NSNumber numberWithInteger:kAudioFormatMPEG4AAC],
                                               AVSampleRateKey:[NSNumber numberWithFloat:currentASBD->mSampleRate],
                                               AVEncoderBitRatePerChannelKey:[NSNumber numberWithInt:64000],
                                               AVNumberOfChannelsKey:[NSNumber numberWithInteger:currentASBD->mChannelsPerFrame],
                                               AVChannelLayoutKey:currentChannelLayoutData};
    
    if ([_assetWriter canApplyOutputSettings:audioCompressionSettings forMediaType:AVMediaTypeAudio])
    {
        _assetAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioCompressionSettings];
        _assetAudioInput.expectsMediaDataInRealTime = YES;
        if ([_assetWriter canAddInput:_assetAudioInput]){
            [_assetWriter addInput:_assetAudioInput];
        }
        else{
            [self showError:_assetWriter.error];
            return NO;
        }
    }
    else{
        [self showError:_assetWriter.error];
        return NO;
    }
    return YES;
}

// 配置视频源数据写入
- (BOOL)setupAssetWriterVideoInput:(CMFormatDescriptionRef)currentFormatDescription
{
    CGFloat bitsPerPixel;
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(currentFormatDescription);
    NSUInteger numPixels = dimensions.width * dimensions.height;
    NSUInteger bitsPerSecond;
    
    if (numPixels < (640 * 480)){
        bitsPerPixel = 4.05;
    }
    else{
        bitsPerPixel = 11.4;
    }
    
    bitsPerSecond = numPixels * bitsPerPixel;
    NSDictionary *videoCompressionSettings = @{AVVideoCodecKey:AVVideoCodecH264,
                                               AVVideoWidthKey:[NSNumber numberWithInteger:dimensions.width],
                                               AVVideoHeightKey:[NSNumber numberWithInteger:dimensions.height],
                                               AVVideoCompressionPropertiesKey:@{AVVideoAverageBitRateKey:[NSNumber numberWithInteger:bitsPerSecond],
                                                                                 AVVideoMaxKeyFrameIntervalKey:[NSNumber numberWithInteger:30]}
                                               };
    if ([_assetWriter canApplyOutputSettings:videoCompressionSettings forMediaType:AVMediaTypeVideo])
    {
        _assetVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoCompressionSettings];
        _assetVideoInput.expectsMediaDataInRealTime = YES;
        _assetVideoInput.transform = [self transformFromCurrentVideoOrientationToOrientation:self.referenceOrientation];
        if ([_assetWriter canAddInput:_assetVideoInput]){
            [_assetWriter addInput:_assetVideoInput];
        }
        else{
            [self showError:_assetWriter.error];
            return NO;
        }
    }
    else{
        [self showError:_assetWriter.error];
        return NO;
    }
    return YES;
}

// 旋转视频方向
- (CGAffineTransform)transformFromCurrentVideoOrientationToOrientation:(AVCaptureVideoOrientation)orientation
{
    CGFloat orientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:orientation];
    CGFloat videoOrientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:self.motionManager.videoOrientation];
    CGFloat angleOffset;
    if ([self activeCamera].position == AVCaptureDevicePositionBack) {
        angleOffset = orientationAngleOffset - videoOrientationAngleOffset;
    }
    else{
        angleOffset = videoOrientationAngleOffset - orientationAngleOffset + M_PI_2;
    }
    CGAffineTransform transform = CGAffineTransformMakeRotation(angleOffset);
    return transform;
}

- (CGFloat)angleOffsetFromPortraitOrientationToOrientation:(AVCaptureVideoOrientation)orientation
{
    CGFloat angle = 0.0;
    switch (orientation)
    {
        case AVCaptureVideoOrientationPortrait:
            angle = 0.0;
            break;
        case AVCaptureVideoOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case AVCaptureVideoOrientationLandscapeRight:
            angle = -M_PI_2;
            break;
        case AVCaptureVideoOrientationLandscapeLeft:
            angle = M_PI_2;
            break;
        default:
            break;
    }
    return angle;
}

#pragma mark -- dismiss
- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - 转换前后摄像头
- (void)swicthCameraAction:(CCCameraView *)cameraView succ:(void (^)(void))succ fail:(void (^)(NSError *))fail
{
    if (_currentflashMode == AVCaptureFlashModeOn) {
        [self setFlashMode:AVCaptureFlashModeOff];
    }
    if (_currentflashMode == AVCaptureFlashModeOn) {
        self.flashBtn.backgroundColor = [UIColor lightGrayColor];
    }else {
        self.flashBtn.backgroundColor = [UIColor clearColor];
    }
    [self.mGPUVideoCamera rotateCamera];
    if (self.mGPUVideoCamera.horizontallyMirrorFrontFacingCamera) {
        self.mGPUVideoCamera.horizontallyMirrorFrontFacingCamera = NO;
        [self.mGPUVideoCamera removeAllTargets];
        [self.mGPUVideoCamera addTarget:self.mView];
    }else {
        self.mGPUVideoCamera.horizontallyMirrorFrontFacingCamera = YES;
        [self.mGPUVideoCamera removeAllTargets];
//        [self.mGPUVideoCamera addTarget:self.filter];
//        [self.filter addTarget:self.mView];
        [self.mGPUVideoCamera addTarget:self.mView];
    }
//    self.mGPUVideoCamera.outputImageOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    _captureSession = self.mGPUVideoCamera.captureSession;
    NSError *error;
    [self setupSessionInputs:&error];
    [self setupSessionOutputs:&error];
    
//    NSError *error;
//    if (self.mGPUVideoCamera.inputCamera.position == AVCaptureDevicePositionFront) {
//        [self setupSession:&error position:AVCaptureDevicePositionBack];
//    }else {
//        [self setupSession:&error position:AVCaptureDevicePositionBack];
//    }
//    [self startCaptureSession];
//    [_captureSession beginConfiguration];
//    _videoConnection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
//    _videoConnection.videoOrientation = self.referenceOrientation;
//    [_captureSession commitConfiguration];
//    id error = [self switchCameras];
//    error?!fail?:fail(error):!succ?:succ();
}

- (BOOL)canSwitchCameras
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1;
}

- (id)switchCameras
{
    if (![self canSwitchCameras]) return nil;
    NSError *error;
    AVCaptureDevice *videoDevice = [self inactiveCamera];                   
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if (videoInput) {
        [_captureSession beginConfiguration];                           
        [_captureSession removeInput:_deviceInput];            
        if ([_captureSession canAddInput:videoInput]) {                 
            [_captureSession addInput:videoInput];
            _deviceInput = videoInput;
        }
        [_captureSession commitConfiguration];
        
        // 如果从后置转前置，会关闭手电筒，如果之前打开的，需要通知camera更新UI
        if (videoDevice.position == AVCaptureDevicePositionFront) {
            [self.cameraView changeTorch:NO];
        }
        // 闪关灯，前后摄像头的闪光灯是不一样的，所以在转换摄像头后需要重新设置闪光灯
        [self changeFlash:_currentflashMode];
        
        // 由于前置摄像头不支持视频，所以当你转换到前置摄像头时，视频输出就无效了，所以在转换回来时，需要把原来的删除了，在重新加一个新的进去
        [_captureSession beginConfiguration];
        [_captureSession removeOutput:_videoOutput];
        
        AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc] init];
        [videoOut setAlwaysDiscardsLateVideoFrames:YES];
        [videoOut setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]}];
        dispatch_queue_t videoCaptureQueue = dispatch_queue_create("Video Capture Queue", DISPATCH_QUEUE_SERIAL);
        [videoOut setSampleBufferDelegate:self queue:videoCaptureQueue];
        
        if ([_captureSession canAddOutput:videoOut]) {
            [_captureSession addOutput:videoOut];
            _videoOutput = videoOut;
        }
        _videoConnection = [videoOut connectionWithMediaType:AVMediaTypeVideo];
        _videoConnection.videoOrientation = self.referenceOrientation;
        [_captureSession commitConfiguration];
        return nil;
    } 
    return error;
}

#pragma mark 打开相册
- (void)openPhotos:(CCCameraView *)cameraView succ:(void (^)(void))succ fail:(void (^)(NSError *))fail {
    
    self.mView.hidden = YES;
    self.backImageView.hidden = NO;
    TZImagePickerController *vc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
    [vc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos,NSArray *assets,BOOL isSelectOriginalPhoto){
        UIImage *image = photos.firstObject;
        CCImagePreviewController *vc = [[CCImagePreviewController alloc] initWithImage:image frame:self.view.frame imgOrientation:UIDeviceOrientationUnknown];
        vc.delegate = self;
        [self presentViewController:vc animated:NO completion:^{
            isIntoBg = YES;
            self.mView.hidden = NO;
            self.backImageView.hidden = YES;
        }];
        
    }];
    
    [vc setImagePickerControllerDidCancelHandle:^{
        self.mView.hidden = NO;
        self.backImageView.hidden = YES;
    }];
    
    [self presentViewController:vc animated:YES completion:^{
        
    }];

}

#pragma mark - 聚焦
-(void)focusAction:(CCCameraView *)cameraView point:(CGPoint)point succ:(void (^)(void))succ fail:(void (^)(NSError *))fail
{
    id error = [self focusAtPoint:point];
    error?!fail?:fail(error):!succ?:succ();
}

- (BOOL)cameraSupportsTapToFocus
{
    return [[self activeCamera] isFocusPointOfInterestSupported];
}

- (id)focusAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = [self activeCamera];
    if ([self cameraSupportsTapToFocus] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus])
    {
        NSError *error;
        if ([device lockForConfiguration:&error]) {                         
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        } 
        return error;
    }
    return nil;
}

#pragma mark - 曝光
-(void)exposAction:(CCCameraView *)cameraView point:(CGPoint)point succ:(void (^)(void))succ fail:(void (^)(NSError *))fail
{
    id error = [self exposeAtPoint:point];
    error?!fail?:fail(error):!succ?:succ();
}

- (BOOL)cameraSupportsTapToExpose
{
    return [[self activeCamera] isExposurePointOfInterestSupported];
}

static const NSString *CameraAdjustingExposureContext;
- (id)exposeAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = [self activeCamera];
    if ([self cameraSupportsTapToExpose] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {                         
            device.exposurePointOfInterest = point;
            device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            if ([device isExposureModeSupported:AVCaptureExposureModeLocked]) {
                [device addObserver:self forKeyPath:@"adjustingExposure" options:NSKeyValueObservingOptionNew context:&CameraAdjustingExposureContext];
            }
            [device unlockForConfiguration];
        } 
        return error;
    }
    return nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if (context == &CameraAdjustingExposureContext) {                     
        AVCaptureDevice *device = (AVCaptureDevice *)object;
        if (!device.isAdjustingExposure && [device isExposureModeSupported:AVCaptureExposureModeLocked]) {
            // 锁定曝光完成了
            [object removeObserver:self forKeyPath:@"adjustingExposure" context:&CameraAdjustingExposureContext];
            dispatch_async(dispatch_get_main_queue(), ^{                    
                NSError *error;
                if ([device lockForConfiguration:&error]) {
                    device.exposureMode = AVCaptureExposureModeLocked;
                    [device unlockForConfiguration];
                } 
                else{
                    [self showError:error];
                }
            });
        }
    } 
    else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - 自动聚焦、曝光
-(void)autoFocusAndExposureAction:(CCCameraView *)cameraView succ:(void (^)(void))succ fail:(void (^)(NSError *))fail
{
    id error = [self resetFocusAndExposureModes];
    error?!fail?:fail(error):!succ?:succ();
}

- (id)resetFocusAndExposureModes
{
    AVCaptureDevice *device = [self activeCamera];
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;
    BOOL canResetFocus = [device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode];
    BOOL canResetExposure = [device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode];
    CGPoint centerPoint = CGPointMake(0.5f, 0.5f);                          
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        if (canResetFocus) {                                                
            device.focusMode = focusMode;
            device.focusPointOfInterest = centerPoint;
        }
        if (canResetExposure) {                                             
            device.exposureMode = exposureMode;
            device.exposurePointOfInterest = centerPoint;
        }
        [device unlockForConfiguration];
    } 
    return error;
}

#pragma mark - 闪光灯
-(void)flashLightAction:(CCCameraView *)cameraView succ:(void (^)(void))succ fail:(void (^)(NSError *))fail
{
    self.flashBtn = cameraView.flashBtn;
    id error = [self changeFlash:[self flashMode] == AVCaptureFlashModeOn?AVCaptureFlashModeOff:AVCaptureFlashModeOn];
    error?!fail?:fail(error):!succ?:succ();
    if (_currentflashMode == AVCaptureFlashModeOn) {
        cameraView.flashBtn.backgroundColor = [UIColor lightGrayColor];
    }else {
        cameraView.flashBtn.backgroundColor = [UIColor clearColor];
    }
}

- (BOOL)cameraHasFlash {
    return [[self activeCamera] hasFlash];
}

- (AVCaptureFlashMode)flashMode{
    return [[self activeCamera] flashMode];
}

- (id)changeFlash:(AVCaptureFlashMode)flashMode{
    if (![self cameraHasFlash]) {
        NSDictionary *desc = @{NSLocalizedDescriptionKey:@"不支持闪光灯"};
        NSError *error = [NSError errorWithDomain:@"com.cc.camera" code:401 userInfo:desc];
        return error;
    }
    // 如果手电筒打开，先关闭手电筒
    if ([self torchMode] == AVCaptureTorchModeOn) {
        [self setTorchMode:AVCaptureTorchModeOff];
    }
    return [self setFlashMode:flashMode];
}

- (id)setFlashMode:(AVCaptureFlashMode)flashMode{
    AVCaptureDevice *device = [self activeCamera];
    if ([device isFlashModeSupported:flashMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.flashMode = flashMode;
            [device unlockForConfiguration];
            _currentflashMode = flashMode;
        }
        return error;
    }
    return nil;
}

#pragma mark - 手电筒
-(void)torchLightAction:(CCCameraView *)cameraView succ:(void (^)(void))succ fail:(void (^)(NSError *))fail
{
    id error =  [self changeTorch:[self torchMode] == AVCaptureTorchModeOn?AVCaptureTorchModeOff:AVCaptureTorchModeOn];
    error?!fail?:fail(error):!succ?:succ();
}

- (BOOL)cameraHasTorch {
    return [[self activeCamera] hasTorch];
}

- (AVCaptureTorchMode)torchMode {
    return [[self activeCamera] torchMode];
}

- (id)changeTorch:(AVCaptureTorchMode)torchMode{
    if (![self cameraHasTorch]) {
        NSDictionary *desc = @{NSLocalizedDescriptionKey:@"不支持手电筒"};
        NSError *error = [NSError errorWithDomain:@"com.cc.camera" code:403 userInfo:desc];
        return error;
    }
    // 如果闪光灯打开，先关闭闪光灯
    if ([self flashMode] == AVCaptureFlashModeOn) {
        [self setFlashMode:AVCaptureFlashModeOff];
    }
    return [self setTorchMode:torchMode];
}

- (id)setTorchMode:(AVCaptureTorchMode)torchMode{
    AVCaptureDevice *device = [self activeCamera];
    if ([device isTorchModeSupported:torchMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.torchMode = torchMode;
            [device unlockForConfiguration];
        }
        return error;
    }
    return nil;
}

#pragma mark - 取消拍照
- (void)cancelAction:(CCCameraView *)cameraView{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 转换拍摄类型
-(void)didChangeTypeAction:(CCCameraView *)cameraView type:(NSInteger)type
{
    
}

#pragma mark - 拍照/录影点击事件
- (void)takePhotoAction:(CCCameraView *)cameraView
{
//    [self takePictureImage];
    [self takePhoto];
}

-(void)startRecordVideoAction:(CCCameraView *)cameraView
{
    [self startRecording];
}

-(void)stopRecordVideoAction:(CCCameraView *)cameraView
{
    [self stopRecording];
}

#pragma mark - Private methods
// 调整设备取向
- (AVCaptureVideoOrientation)currentVideoOrientation{
    AVCaptureVideoOrientation orientation;
    switch (self.motionManager.deviceOrientation) { 
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
    }
    return orientation;
}

// 移除文件
- (void)removeFile:(NSURL *)fileURL
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = fileURL.path;
    if ([fileManager fileExistsAtPath:filePath])
    {
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:filePath error:&error];
        if (!success){
            [self showError:error];
        }
        else{
            NSLog(@"删除视频文件成功");
        }
    }
}

// 展示错误
- (void)showError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
       [self.view showAlertView:self title:error.localizedDescription message:error.localizedFailureReason sureTitle:@"确定" cancelTitle:nil sure:nil cancel:nil];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 方向
- (UIDeviceOrientation)takePhoto {
    
    if([self.cmmotionManager isDeviceMotionAvailable]) {
        
        __block UIDeviceOrientation orientationNew = UIDeviceOrientationUnknown;
        [self.cmmotionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
            CMAcceleration acceleration = accelerometerData.acceleration;
        
            if (acceleration.x >= 0.75) {//home button left
                orientationNew = UIDeviceOrientationLandscapeRight;
                NSLog(@"右");
                [self takePictureImage:orientationNew];
                [self.cmmotionManager stopAccelerometerUpdates];
            }
            else if (acceleration.x <= -0.75) {//home button right
                orientationNew = UIDeviceOrientationLandscapeLeft;
                NSLog(@"左");
                [self takePictureImage:orientationNew];
                [self.cmmotionManager stopAccelerometerUpdates];
            }
            else if (acceleration.y <= -0.75) {
                orientationNew = UIDeviceOrientationPortrait;
                NSLog(@"上");
                [self takePictureImage:orientationNew];
                [self.cmmotionManager stopAccelerometerUpdates];
            }
            else if (acceleration.y >= 0.75) {
                orientationNew = UIDeviceOrientationPortraitUpsideDown;
                NSLog(@"下");
                [self takePictureImage:orientationNew];
                [self.cmmotionManager stopAccelerometerUpdates];
            }
            else {
                // Consider same as last time
                [self takePictureImage:orientationNew];
                [self.cmmotionManager stopAccelerometerUpdates];
                return;
            }

        }];
  
        return orientationNew;
    
    }
    
    return UIDeviceOrientationUnknown;
}

- (void)present:(UIViewController *)vc {
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - 音量键拍照
- (void)intoBackg
{
    NSLog(@"***************后台出来*****************");
//    volumeViewSlider.value = self.volume;
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    self.volume = [[AVAudioSession sharedInstance] outputVolume];
    isIntoBg = NO;
}

- (void)returnBackg
{
    NSLog(@"***************进入后台*****************");
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
//    volumeViewSlider.value = self.volume;
    isIntoBg = YES;
}

-(void)volumeChanged:(NSNotification *)noti

{
    
    NSDate *now = [NSDate date];
    NSTimeInterval interval = [now timeIntervalSinceDate:_lastLongPressDate];
    _lastLongPressDate = now;
    
    if (interval < 0.2f) {
        return;
    }
    
    NSString *str1 = [[noti userInfo]objectForKey:@"AVSystemController_AudioCategoryNotificationParameter"];
    NSString *str2 = [[noti userInfo]objectForKey:@"AVSystemController_AudioVolumeChangeReasonNotificationParameter"];
    //此处判断将音量调节和铃声调节都包括进来进行响应
    if (([str1 isEqualToString:@"Audio/Video"] || [str1 isEqualToString:@"Ringtone"]) && ([str2 isEqualToString:@"ExplicitVolumeChange"]))
    {
        if(isIntoBg == NO){
            //这里做你想要的进行的操作
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
            volumeViewSlider.value = self.volume;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
            [self takePhoto];
        }
    }
    
}

@end
