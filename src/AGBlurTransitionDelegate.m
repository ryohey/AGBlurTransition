//
//  AGBlurTransitionDelegate.m
//  BlurTransitionExample
//
//  Created by Angel Garcia on 02/01/14.
//  Copyright (c) 2014 angelolloqui.com. All rights reserved.
//

#import "AGBlurTransitionDelegate.h"
#import <Accelerate/Accelerate.h>

@interface AGBlurTransitionDelegate ()

@property (nonatomic) UIView *backgroundView;
@property (nonatomic, weak) UIViewController *originalViewController;

@end

@implementation AGBlurTransitionDelegate

- (id)init {
    self = [super init];
    if (self) {
        _duration = 0.5f;
        _tintColor = [UIColor colorWithWhite:0 alpha:0.3];
        _blurRadius = 20;
        _saturationDeltaFactor = 1.8;
        _insets = UIEdgeInsetsMake(20, 20, 20, 20);
        _cornerRadius = 0;
        _openDamping = 0.6;
        _closePreshootScale = 1.2;
        _closePreshootDuration = 0.2;
        _closeFinalScale = 0.00001;
    }
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning methods

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning methods

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    if (!self.originalViewController) {
        self.originalViewController = fromViewController;
    }
    
    if (fromViewController == self.originalViewController) {
        [self animateOpenTransition:transitionContext];
    }
    else if (toViewController == self.originalViewController) {
        [self animateCloseTransition:transitionContext];
    }
    else {
        [[transitionContext containerView] addSubview:toViewController.view];
        [transitionContext completeTransition:YES];
        //TODO: Handle error!
    }
}


#pragma mark - Helpers

- (void)animateOpenTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    // Obtain state from the context
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    CGRect finalFrame = [transitionContext finalFrameForViewController:toViewController];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    UIView *containerView = [transitionContext containerView];
    
    // Add the view and backgrounds
    self.backgroundView = [[UIView alloc] initWithFrame:finalFrame];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundView.backgroundColor = [UIColor clearColor];
    
    UIView *snapshot = [fromViewController.view snapshotViewAfterScreenUpdates:YES];
    snapshot.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.backgroundView addSubview:snapshot];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *effectView = [UIVisualEffectView.alloc initWithEffect:blurEffect];
    effectView.frame = self.backgroundView.bounds;
    effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    effectView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    [self.backgroundView addSubview:effectView];
    
    [containerView addSubview:self.backgroundView];
    
    toViewController.view.frame = UIEdgeInsetsInsetRect(finalFrame, self.insets);
    toViewController.view.layer.cornerRadius = self.cornerRadius;
    [containerView addSubview:toViewController.view];
    
    // Set initial state of animation
    if (self.animationType == AGBlurTransitionAnimationTypeSlide) {
        toViewController.view.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0.f, toViewController.view.frame.size.height);
    } else {
        toViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    }
    self.backgroundView.alpha = 0.0;
    
    // Animate
    [UIView animateWithDuration:duration
                          delay:0.0
         usingSpringWithDamping:_openDamping
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         toViewController.view.transform = CGAffineTransformIdentity;
                         self.backgroundView.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         // Inform the context of completion
                         [transitionContext completeTransition:YES];
                     }];
}

- (void)animateCloseTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    // Obtain state from the context
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    UIView *containerView = [transitionContext containerView];
    
    // Add the view and backgrounds
    [containerView addSubview:toViewController.view];
    [containerView addSubview:self.backgroundView];
    [containerView addSubview:fromViewController.view];
    
    // Animate with keyframes
    [UIView animateKeyframesWithDuration:duration
                                   delay:0.0
                                 options:UIViewKeyframeAnimationOptionCalculationModeCubic
                              animations:^{
                                  
                                  if (_closePreshootDuration > FLT_EPSILON) {
                                      // keyframe one
                                      [UIView addKeyframeWithRelativeStartTime:0.0
                                                              relativeDuration:_closePreshootDuration
                                                                    animations:^{
                                                                        if (self.animationType == AGBlurTransitionAnimationTypeSlide) {
                                                                            fromViewController.view.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, -fromViewController.view.frame.size.height * (_closePreshootScale - 1.0));
                                                                        }
                                                                        else {
                                                                            fromViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, _closePreshootScale, _closePreshootScale);
                                                                        }
                                                                    }];
                                  }
                                  // keyframe two
                                  [UIView addKeyframeWithRelativeStartTime:_closePreshootDuration
                                                          relativeDuration:0.6
                                                                animations:^{
                                                                    if (self.animationType == AGBlurTransitionAnimationTypeSlide) {
                                                                        fromViewController.view.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, fromViewController.view.frame.size.height + self.insets.top);
                                                                    }
                                                                    else {
                                                                        fromViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, _closeFinalScale, _closeFinalScale);
                                                                    }
                                                                    self.backgroundView.alpha = 0.0;
                                                                }];
                                  [UIView addKeyframeWithRelativeStartTime:0.0
                                                          relativeDuration:1.0
                                                                animations:^{
                                                                    self.backgroundView.alpha = 0.0;
                                                                    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
                                                                }];
                              }
     
                              completion:^(BOOL finished) {
                                  [self.backgroundView removeFromSuperview];
                                  self.backgroundView = nil;
                                  [transitionContext completeTransition:YES];
                              }];
}

@end
