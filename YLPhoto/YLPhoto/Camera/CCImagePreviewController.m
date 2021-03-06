//
//  CCImagePreviewController.m
//  CCCamera
//
//  Created by wsk on 16/8/22.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "CCImagePreviewController.h"
#import "UIImage+fixOrientation.h"
#import <GPUImage.h>
#import "FWBeautyViewController.h"

@interface CCImagePreviewController ()
{
    UIImage *_image;
    CGRect   _frame;
    UIDeviceOrientation _deviceOrientation;
    UIDeviceOrientation _lastOrientation;
    UIImage *_originalImage;
}
@property (nonatomic,weak) UIButton *saveButton;
@property (nonatomic,weak) UIImageView *imageView;

@end

@implementation CCImagePreviewController

- (instancetype)initWithImage:(UIImage *)image frame:(CGRect)frame imgOrientation:(UIDeviceOrientation)imgOrientation{
    if (self = [super initWithNibName:nil bundle:nil]) {
        _image = image;
        _frame = frame;
        _deviceOrientation = imgOrientation;
        _originalImage = image;
    }
    return self;
}

- (instancetype)init{
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Use -initWithImage: frame:" userInfo:nil];
}

+ (instancetype)new{
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Use -initWithImage: frame:" userInfo:nil];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    return [self initWithImage:nil frame:CGRectZero imgOrientation:0];
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    return [self initWithImage:nil frame:CGRectZero imgOrientation:0];
}

- (void)viewDidLoad {
    [self hideStatusBar];
    [super viewDidLoad];
    [self setupUI];
}

//-(UIImage *)scaleToSize:(UIImage *)image size:(CGSize)size
//{
//    //创建一个bitmap的context
//    //并把他设置成当前的context
////    UIGraphicsBeginImageContext(size);
////    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
//    
//    //绘制图片的大小
//    if (image.size.height > image.size.width) {
//        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
//        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
//    }else {
//        
//        switch (_deviceOrientation) {
//            case UIDeviceOrientationLandscapeLeft:
//                _lastOrientation = _deviceOrientation;
//                image = [UIImage imageWithCGImage:[image CGImage] scale:[UIScreen mainScreen].scale orientation:UIImageOrientationLeft];
//                break;
//            case UIDeviceOrientationLandscapeRight:
//                _lastOrientation = _deviceOrientation;
//                image = [UIImage imageWithCGImage:[image CGImage] scale:[UIScreen mainScreen].scale orientation:UIImageOrientationRight];
//                break;
//            case UIDeviceOrientationPortrait:{
//                UIImageOrientation imgOrientation = [self changeDeviceToImageOrientation:_lastOrientation];
//                image = [UIImage imageWithCGImage:[image CGImage] scale:[UIScreen mainScreen].scale orientation:imgOrientation];
//            }
//                break;
//            default:
//                image = [UIImage imageWithCGImage:[image CGImage] scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
//                break;
//        }
//        
//        CGSize newSize = CGSizeMake(size.width, size.width * image.size.height / image.size.width);
//        UIGraphicsBeginImageContextWithOptions(newSize, NO, [UIScreen mainScreen].scale);
//        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
//    }
//    
////    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
//    
//    //从当前context中创建一个改变大小后的图片
//    UIImage *endImage = UIGraphicsGetImageFromCurrentImageContext();
//    
//    UIGraphicsEndImageContext();
//    return endImage;
//}

-(UIImage *)scaleToSize:(UIImage *)image size:(CGSize)size
{
    //创建一个bitmap的context
    //并把他设置成当前的context
    //    UIGraphicsBeginImageContext(size);
    //    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    //绘制图片的大小
    if (image.size.height > image.size.width) {
//        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
//        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    }else {
        
        switch (_deviceOrientation) {
            case UIDeviceOrientationLandscapeLeft:
                _lastOrientation = _deviceOrientation;
                image = [UIImage imageWithCGImage:[image CGImage] scale:[UIScreen mainScreen].scale orientation:UIImageOrientationLeft];
                break;
            case UIDeviceOrientationLandscapeRight:
                _lastOrientation = _deviceOrientation;
                image = [UIImage imageWithCGImage:[image CGImage] scale:[UIScreen mainScreen].scale orientation:UIImageOrientationRight];
                break;
            case UIDeviceOrientationPortrait:{
                UIImageOrientation imgOrientation = [self changeDeviceToImageOrientation:_lastOrientation];
                image = [UIImage imageWithCGImage:[image CGImage] scale:[UIScreen mainScreen].scale orientation:imgOrientation];
            }
                break;
            default:
                image = [UIImage imageWithCGImage:[image CGImage] scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
                break;
        }
        
//        CGSize newSize = CGSizeMake(size.width, size.width * image.size.height / image.size.width);
//        UIGraphicsBeginImageContextWithOptions(newSize, NO, [UIScreen mainScreen].scale);
//        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    }
    
    //    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    //从当前context中创建一个改变大小后的图片
//    UIImage *endImage = UIGraphicsGetImageFromCurrentImageContext();
//    
//    UIGraphicsEndImageContext();
//    return endImage;
    return image;
}


- (UIImageOrientation)changeDeviceToImageOrientation:(UIDeviceOrientation)device {
    
    UIImageOrientation imgOrientation = UIImageOrientationUp;
    switch (device) {
        case UIDeviceOrientationLandscapeLeft:
            imgOrientation = UIImageOrientationLeft;
            break;
        case UIDeviceOrientationLandscapeRight:
            imgOrientation = UIImageOrientationRight;
            break;
        default:
            break;
    }
    return imgOrientation;
}

- (void)setupUI {
    
    self.view.backgroundColor = [UIColor whiteColor];
    _image = [self scaleToSize:_image size:_frame.size];
    _image = [_image fixOrientation];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:_image];
    self.imageView = imageView;
    imageView.backgroundColor = [UIColor whiteColor];
    imageView.userInteractionEnabled = YES;
    imageView.layer.masksToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = CGRectMake(0, 0, _frame.size.width, _frame.size.height);
    [self.view addSubview:imageView];
    
    // 透明遮罩
    UIView *coverView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:coverView];
    
    // 返回按钮
    UIButton *backButton = [[UIButton alloc] init];
    [backButton setBackgroundImage:[UIImage imageNamed:@"global_close_shadow"] forState:UIControlStateNormal];
    backButton.frame = CGRectMake(20, coverView.height - 100, 40, 40);
    [backButton addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
    [coverView addSubview:backButton];
    
    // 保存图片按钮
    UIButton *saveButton = [[UIButton alloc] init];
    self.saveButton = saveButton;
    self.saveButton.userInteractionEnabled = YES;
    [saveButton setImage:[UIImage imageNamed:@"end_save_gif"] forState:UIControlStateNormal];
    [saveButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    saveButton.backgroundColor = [UIColor whiteColor];
    saveButton.center = CGPointMake(coverView.width * 0.5 , coverView.height - 80);
    saveButton.bounds = CGRectMake(0, 0, 60, 60);
    saveButton.layer.cornerRadius = 30;
    saveButton.layer.masksToBounds = YES;
    [saveButton addTarget:self action:@selector(saveImageToPhotos) forControlEvents:UIControlEventTouchUpInside];
    [coverView addSubview:saveButton];
    
    // 添加滤镜按钮
    UIButton *filterButton = [[UIButton alloc] init];
    [filterButton setBackgroundImage:[UIImage imageNamed:@"filter_icon_filter"] forState:UIControlStateNormal];
    [filterButton addTarget:self action:@selector(addFilter:) forControlEvents:UIControlEventTouchUpInside];
    filterButton.frame = CGRectMake(coverView.width - 70, coverView.height - 100, 40, 40);
    [coverView addSubview:filterButton];
}

- (void)addFilter:(UIButton *)btn {
    
//    GPUImageSepiaFilter *filter = [[GPUImageSepiaFilter alloc] init]; // 褐色(怀旧)
//    GPUImageSobelEdgeDetectionFilter *filter = [[GPUImageSobelEdgeDetectionFilter alloc] init];
//    _image = [filter imageByFilteringImage:_image];
//    self.imageView.image = _image;
//    btn.enabled = NO;
    
    FWBeautyViewController *fw = [[FWBeautyViewController alloc] initWithImage:_image];
    [self dismissViewControllerAnimated:NO completion:^{
        [self.delegate present:fw];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissSelf {
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
}

- (void)saveImageToPhotos {
    UIImageWriteToSavedPhotosAlbum(_image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

// 指定回调方法

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo

{
    UIImage *showImage;
    
    if(error != NULL){
        showImage = [UIImage imageNamed:@"alert_ico_page_02"];
    }else{
        showImage = [UIImage imageNamed:@"download_confirm"];
    }

    [UIView animateWithDuration:0.75 animations:^{
        [self.saveButton setImage:showImage forState:UIControlStateNormal];
    } completion:^(BOOL finished) {
        self.saveButton.userInteractionEnabled = NO;
    }];
    
}

- (UIImage *)fitSmallImage:(UIImage *)image {
    
    if (nil == image) {
        
        return nil;
        
    }
    
    if (image.size.width < 1000.0f || image.size.height < 1000) {
        
        return image;
        
    }
    
    
    
    //    CGSize size = CGSizeMake(1000.0f, 1334.0f);3264 2448
    
    NSInteger ks = 2;
    
    if (image.size.width>image.size.height) {
        
        ks = (image.size.width)/1000;
        
    }else{
        
        ks = (image.size.height)/1000;
        
    }
    
    CGSize size = CGSizeMake(image.size.width/ks, image.size.height/ks);
    
    UIGraphicsBeginImageContext(size);
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    [image drawInRect:rect];
    
    UIImage *newing = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newing;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
