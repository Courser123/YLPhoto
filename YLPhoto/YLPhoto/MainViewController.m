//
//  MainViewController.m
//  YLPhoto
//
//  Created by 王忠迪 on 08/08/2017.
//  Copyright © 2017 王忠迪. All rights reserved.
//

#import "MainViewController.h"
#import "LDSDKHeartFlyView.h"
#import "YLCameraViewController.h"
#import "CCCameraViewController.h"
#import <GPUImage.h>
#import <TZImagePickerController.h>
#import <AVFoundation/AVFoundation.h>

#define kMusicFile @"郑国锋-倚栏听风.mp3"

@interface MainViewController () <UIViewControllerTransitioningDelegate,TZImagePickerControllerDelegate,AVAudioPlayerDelegate>

@property (nonatomic,strong) UIScrollView *mainScrollView;
@property (nonatomic,strong) UIImageView *mainnScrollViewImageView;
@property (nonatomic,strong) CADisplayLink *displayLink;
@property (nonatomic,assign) double contentOffsetX;
@property (nonatomic,strong) UIImageView *testImageView;
@property (nonatomic,strong) UIButton *recordBtn;
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;//播放器
@property (nonatomic,strong) UIButton *playBtn;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _contentOffsetX = 0;
    self.navigationController.navigationBar.hidden = YES;
    _mainScrollView = [[UIScrollView alloc] init];
    _mainScrollView.showsVerticalScrollIndicator = NO;
    _mainScrollView.showsHorizontalScrollIndicator = NO;
    _mainnScrollViewImageView = [[UIImageView alloc] init];
    _mainScrollView.bounces = NO;
    
    _mainnScrollViewImageView.image = [UIImage imageNamed:@"WechatIMG86.jpeg"];
    _mainnScrollViewImageView.contentMode = UIViewContentModeScaleToFill;
    [_mainScrollView addSubview:_mainnScrollViewImageView];
    [self.view addSubview:_mainScrollView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTheMainScrollView)];
    [_mainScrollView addGestureRecognizer:tap];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tapTheMainScrollView)];
    [_mainScrollView addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tapTheMainScrollView)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [_mainScrollView addGestureRecognizer:swipeLeft];
    
    _recordBtn = [[UIButton alloc] init];
    [_recordBtn setBackgroundImage:[UIImage imageNamed:@"timg1.jpg"] forState:UIControlStateNormal];
    _recordBtn.bounds = CGRectMake(0, 0, 60, 60);
    _recordBtn.layer.cornerRadius = 30;
    _recordBtn.layer.masksToBounds = YES;
    [_recordBtn addTarget:self action:@selector(tapRecordBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_recordBtn];
    
    // 设置各种功能按键
    _playBtn = [[UIButton alloc] init];
    [self.view addSubview:_playBtn];
    [_playBtn addTarget:self action:@selector(playOrPause:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)moveTheScrollView {
//    if (_mainScrollView.contentOffset.x <= 107) {
//        _contentOffsetX = 0.3;
//        _mainScrollView.contentOffset = CGPointMake(_mainScrollView.contentOffset.x + _contentOffsetX, 0);
//    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _mainScrollView.frame = self.view.bounds;
//    _mainScrollView.contentSize = CGSizeMake(self.view.bounds.size.width + 108, self.view.bounds.size.height);
    _mainScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
//    _mainnScrollViewImageView.frame = CGRectMake(0, 0, _mainScrollView.contentSize.width, _mainScrollView.contentSize.height);
    _mainnScrollViewImageView.frame = self.view.bounds;
    _recordBtn.center = CGPointMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height - 100);
    _playBtn.frame = CGRectMake(0, 420, 66, 247);
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)tapTheMainScrollView {
    
    LDSDKHeartFlyView *heartView = [[LDSDKHeartFlyView alloc] initWithFrame:CGRectMake(arc4random_uniform(self.view.size.width - 33), arc4random_uniform(self.view.size.height), 66, 66)];
    [self.mainScrollView addSubview:heartView];
    [heartView animateInView:self.mainScrollView];
    
}

- (void)tapRecordBtn {
    
    CCCameraViewController *vc = [[CCCameraViewController alloc] init];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _mainScrollView.contentOffset = CGPointZero;
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(moveTheScrollView)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self play];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    for (int i = 0; i < 10; i++) {
        [self tapTheMainScrollView];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.displayLink invalidate];
    self.displayLink = nil;
    [self pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
}

#pragma mark - 播放器
/**
 *  创建播放器
 *
 *  @return 音频播放器
 */
-(AVAudioPlayer *)audioPlayer{
    if (!_audioPlayer) {
        NSString *urlStr = [[NSBundle mainBundle]pathForResource:kMusicFile ofType:nil];
        NSURL *url = [NSURL fileURLWithPath:urlStr];
        NSError *error = nil;
        //初始化播放器，注意这里的Url参数只能时文件路径，不支持HTTP Url
        _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        //设置播放器属性
        _audioPlayer.numberOfLoops = 1; //设置为0不循环
        _audioPlayer.delegate = self;
        [_audioPlayer prepareToPlay]; //加载音频文件到缓存
        if(error){
            NSLog(@"初始化播放器过程发生错误,错误信息:%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioPlayer;
}

/**
 *  播放音频
 */
-(void)play{
    if (![self.audioPlayer isPlaying]) {
        [self.audioPlayer play];
    }
}

/**
 *  暂停播放
 */
-(void)pause{
    if ([self.audioPlayer isPlaying]) {
        [self.audioPlayer pause];
    }
}

- (void)playOrPause:(UIButton *)btn {
    if ([self.audioPlayer isPlaying]) {
        [self.audioPlayer pause];
    }else {
        [self.audioPlayer play];
    }
}

#pragma mark - 播放器代理方法
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"音乐播放完成...");
}

@end
