//
//  MyAnimator.m
//  YLPhoto
//
//  Created by 王忠迪 on 20/08/2017.
//  Copyright © 2017 王忠迪. All rights reserved.
//

#import "MyAnimator.h"

@implementation MyAnimator

// 返回动画时长
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 1.0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    // 通过字符串常量Key从转场上下文种获得相应的对象
    UIView *containerView = [transitionContext containerView];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    // 要将toView添加到容器视图中
    [containerView addSubview:toView];
    
    // 自定义动画, 从中间开始进行y方向放大
    // 注意: 这边最好修改transform属性进行动画，否则视图中的子视图将不是你预期的动画效果
    toView.transform = CGAffineTransformMakeScale(1.0, 0);
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        toView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        BOOL success = ![transitionContext transitionWasCancelled];
        // 注意:这边一定要调用这句否则UIKit会一直等待动画完成
        [transitionContext completeTransition:success];
    }];
}

@end
