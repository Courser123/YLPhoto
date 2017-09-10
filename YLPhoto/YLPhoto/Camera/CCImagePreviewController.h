//
//  CCImagePreviewController.h
//  CCCamera
//
//  Created by wsk on 16/8/22.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "CCBaseViewController.h"

@protocol CCImagePreviewControllerDelegate <NSObject>

@required
- (void)present:(UIViewController *)vc;

@end

@interface CCImagePreviewController : CCBaseViewController

@property (nonatomic, weak) id<CCImagePreviewControllerDelegate> delegate;

+ (instancetype)new  NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithImage:(UIImage *)image frame:(CGRect)frame imgOrientation:(UIDeviceOrientation)imgOrientation NS_DESIGNATED_INITIALIZER;

@end
