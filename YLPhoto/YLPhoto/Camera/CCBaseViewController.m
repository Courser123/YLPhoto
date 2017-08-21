//
//  CCBaseViewController.m
//  CCCamera
//
//  Created by wsk on 16/8/22.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "CCBaseViewController.h"

@interface CCBaseViewController ()

@end

@implementation CCBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = UIColorWithHexA(0xebf5ff, 1);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- 隐藏状态栏
- (void)hideStatusBar {
    
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
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
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
