//
//  CCImagePreviewController.m
//  CCCamera
//
//  Created by wsk on 16/8/22.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "CCImagePreviewController.h"

@interface CCImagePreviewController ()
{
    UIImage *_image;
    CGRect   _frame;
}
@property (nonatomic,weak) UIButton *saveButton;
@end

@implementation CCImagePreviewController

- (instancetype)initWithImage:(UIImage *)image frame:(CGRect)frame{
    if (self = [super initWithNibName:nil bundle:nil]) {
        _image = image;
        _frame = frame;
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
    return [self initWithImage:nil frame:CGRectZero];
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    return [self initWithImage:nil frame:CGRectZero];
}

- (void)viewDidLoad {
    [self hideStatusBar];
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI {
    UIImageView *imageView = [[UIImageView alloc]initWithImage:_image];
    imageView.userInteractionEnabled = YES;
    imageView.layer.masksToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
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
    filterButton.frame = CGRectMake(coverView.width - 70, coverView.height - 100, 40, 40);
    [coverView addSubview:filterButton];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
