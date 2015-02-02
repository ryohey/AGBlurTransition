//
//  AGBlurTransitionDelegate.h
//  BlurTransitionExample
//
//  Created by Angel Garcia on 02/01/14.
//  Copyright (c) 2014 angelolloqui.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, AGBlurTransitionAnimationType)
{
    AGBlurTransitionAnimationTypeDefault = 0,
    AGBlurTransitionAnimationTypeSlide
};

@interface AGBlurTransitionDelegate : NSObject <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

/** Configures the animation duration. Defaults to 0.5 */
@property (nonatomic, assign) NSTimeInterval duration;

/** Configures internal modal insets. Defaults to (20, 20, 20, 20) */
@property (nonatomic, assign) UIEdgeInsets insets;

/** Configures blur radius. Defaults to 20 */
@property (nonatomic, assign) CGFloat blurRadius;

/** Configures saturation factor of blur image. Defaults to  1.8 */
@property (nonatomic, assign) CGFloat saturationDeltaFactor;

/** Configures tint color of blur image. Defaults to black 0.3 alpha */
@property (nonatomic, strong) UIColor *tintColor;

/** Configures the style of animation. Defaults to AGBlurTransitionAnimationTypeDefault. */
@property (nonatomic, assign) AGBlurTransitionAnimationType animationType;

/** Configures corner radius. Defaults to 0 */
@property (nonatomic, assign) CGFloat cornerRadius;

/** Configures opening animation damping. Defaults to 0.6 */
@property (nonatomic, assign) CGFloat openDamping;

/** Configures closing preshoot scale. Defaults to 1.2 */
@property (nonatomic, assign) CGFloat closePreshootScale;

/** Configures closing preshoot duration. Defaults to 0.2 */
@property (nonatomic, assign) CGFloat closePreshootDuration;

/** Configures closing animation final scale. Defaults to 0.00001 */
@property (nonatomic, assign) CGFloat closeFinalScale;

@end
