//
//  MainViewController.m
//  YLPhoto
//
//  Created by 王忠迪 on 08/08/2017.
//  Copyright © 2017 王忠迪. All rights reserved.
//

#import "MainViewController.h"
#import "LQPhotoPickerViewController.h"

@interface MainViewController ()

@property (nonatomic,strong) LQPhotoPickerViewController *photoPickerVC;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = [UIColor blueColor];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
