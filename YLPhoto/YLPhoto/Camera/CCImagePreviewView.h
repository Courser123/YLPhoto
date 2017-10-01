//
//  CCImagePreviewView.h
//  YLPhoto
//
//  Created by 王忠迪 on 01/10/2017.
//  Copyright © 2017 王忠迪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FWBeautyViewController.h"

@protocol CCImagePreviewViewDelegate

@end

@interface CCImagePreviewView : UIView

@property (nonatomic, strong) UIImage *originImage;
@property (nonatomic, copy) void(^presentFilterViewController)(FWBeautyViewController *);

- (instancetype)initWithImage:(UIImage *)image frame:(CGRect)frame imgOrientation:(UIDeviceOrientation)imgOrientation;

@end
