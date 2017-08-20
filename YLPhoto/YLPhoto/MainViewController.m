//
//  MainViewController.m
//  YLPhoto
//
//  Created by 王忠迪 on 08/08/2017.
//  Copyright © 2017 王忠迪. All rights reserved.
//

#import "MainViewController.h"
#import "LQPhotoPickerViewController.h"
#import "LDSDKHeartFlyView.h"

@interface MainViewController ()

@property (nonatomic,strong) LQPhotoPickerViewController *photoPickerVC;
@property (nonatomic,strong) UIScrollView *mainScrollView;
@property (nonatomic,strong) UIImageView *mainnScrollViewImageView;
@property (nonatomic,strong) CADisplayLink *displayLink;
@property (nonatomic,assign) double contentOffsetX;
@property (nonatomic,strong) UIImageView *testImageView;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _contentOffsetX = 0;
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = [UIColor blueColor];
    _mainScrollView = [[UIScrollView alloc] init];
//    _mainScrollView.userInteractionEnabled = YES;
    _mainScrollView.showsVerticalScrollIndicator = NO;
    _mainScrollView.showsHorizontalScrollIndicator = NO;
    _mainnScrollViewImageView = [[UIImageView alloc] init];
    _mainScrollView.bounces = NO;
    
    _mainScrollView.backgroundColor = [UIColor blueColor];
    _mainnScrollViewImageView.image = [UIImage imageNamed:@"WechatIMG58.jpeg"];
    _mainnScrollViewImageView.contentMode = UIViewContentModeScaleToFill;
    [_mainScrollView addSubview:_mainnScrollViewImageView];
    [self.view addSubview:_mainScrollView];
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(moveTheScrollView)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    _testImageView = [[UIImageView alloc] init];
    _testImageView.image = [UIImage imageNamed:@"1502889412_765176.png"];
    [_mainScrollView addSubview:_testImageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTheMainScrollView)];
    [_mainScrollView addGestureRecognizer:tap];
    
}

- (void)moveTheScrollView {
    
    if (_mainScrollView.contentOffset.x <= 65) {
        _contentOffsetX = 0.3;
        _mainScrollView.contentOffset = CGPointMake(_mainScrollView.contentOffset.x + _contentOffsetX, 0);
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _mainScrollView.frame = self.view.bounds;
    _mainScrollView.contentSize = CGSizeMake(self.view.bounds.size.width + 66, self.view.bounds.size.height);
    _mainnScrollViewImageView.frame = CGRectMake(0, 0, _mainScrollView.contentSize.width, _mainScrollView.contentSize.height);
    _testImageView.frame = CGRectMake(0, 0, _mainScrollView.contentSize.width, 100);
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

- (void)tapTheMainScrollView {
    LDSDKHeartFlyView *heartView = [[LDSDKHeartFlyView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 108, 200, 66, 66)];
    [self.mainScrollView addSubview:heartView];
    [heartView animateInView:self.mainScrollView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
