//
//  ViewController.m
//  ShimmerDemo
//
//  Created by 翟涛 on 14-3-20.
//  Copyright (c) 2014年 翟涛. All rights reserved.
//

#import "ViewController.h"
#import <Shimmer/FBShimmeringView.h>

@interface ViewController ()

@end

@implementation ViewController
{
    UIImageView *_wallpaperView;
    FBShimmeringView *_shimmeringView;
    UIView *_contentView;
    UILabel *_logoLabel;
    
    UILabel *_valueLabel;
    
    CGFloat _panStartValue;
    BOOL _panVertical;
}
//  隐藏状态栏
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    //  背景层
    _wallpaperView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _wallpaperView.image = [UIImage imageNamed:@"Wallpaper"];
    _wallpaperView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_wallpaperView];
    
    CGRect valueFrame = self.view.bounds;
    valueFrame.size.height = valueFrame.size.height * 0.25;
    
    _valueLabel = [[UILabel alloc] initWithFrame:valueFrame];
    _valueLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:32.0];
    _valueLabel.textColor = [UIColor whiteColor];
    _valueLabel.textAlignment = NSTextAlignmentCenter;
    _valueLabel.numberOfLines = 0;
    _valueLabel.alpha = 0.0;
    [self.view addSubview:_valueLabel];
    
    CGRect shimmeringFrame = self.view.bounds;
    shimmeringFrame.origin.y = shimmeringFrame.size.height * 0.68;
    shimmeringFrame.size.height = shimmeringFrame.size.height * 0.32;
    
    _shimmeringView = [[FBShimmeringView alloc] initWithFrame:shimmeringFrame];
    // 是否闪烁
    _shimmeringView.shimmering = YES;
    // 闪烁的时间间隔
    _shimmeringView.shimmeringBeginFadeDuration = 0.3;
    // 不透明度
    _shimmeringView.shimmeringOpacity = 0.3;
    [self.view addSubview:_shimmeringView];
    
    // 闪烁的Label
    _logoLabel = [[UILabel alloc] initWithFrame:_shimmeringView.bounds];
    _logoLabel.text = @"Shimmer";
    _logoLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:60.0];
    _logoLabel.textColor = [UIColor whiteColor];
    _logoLabel.textAlignment = NSTextAlignmentCenter;
    // 设置闪烁的Label
    _shimmeringView.contentView = _logoLabel;
    
    // 单击手势——回调_tapped方法，开关shimmeringView的闪烁
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapped:)];
    [self.view addGestureRecognizer:tapRecognizer];
    
    // 平移手势——回调_panned方法，控制shimmeringView的闪烁速度
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_panned:)];
    [self.view addGestureRecognizer:panRecognizer];
}

- (void)_tapped:(UITapGestureRecognizer *)tapRecognizer
{
    _shimmeringView.shimmering = !_shimmeringView.shimmering;
}

- (void)_panned:(UIPanGestureRecognizer *)panRecognizer
{
    CGPoint translation = [panRecognizer translationInView:self.view];
    CGPoint velocity = [panRecognizer velocityInView:self.view];
    // 平移开始时
    if (panRecognizer.state == UIGestureRecognizerStateBegan) {
        _panVertical = (fabsf(velocity.y) > fabsf(velocity.x));
        // 如果上下移动的速度大于左右移动的速度，那么控制shimmeringSpeed
        // 否则控制shimmering开始装填的不透明度
        if (_panVertical) {
            _panStartValue = _shimmeringView.shimmeringSpeed;
        } else {
            _panStartValue = _shimmeringView.shimmeringOpacity;
        }
        // 显示_valueLabel的方法
        [self _animateValueLabelVisible:YES];
    } else if (panRecognizer.state == UIGestureRecognizerStateChanged) {
        // 平移过程中，获取移动的点，根据左右或上下的手势，算的调整的比例
        CGFloat directional = (_panVertical ? translation.y : translation.x);
        CGFloat possible = (_panVertical ? self.view.bounds.size.height : self.view.bounds.size.width);
        
        CGFloat progress = (directional / possible);
        
        if (_panVertical) {
            _shimmeringView.shimmeringSpeed = fmaxf(0.0, fminf(1000.0, _panStartValue + progress * 200.0));
            _valueLabel.text = [NSString stringWithFormat:@"Speed\n%.1f", _shimmeringView.shimmeringSpeed];
        } else {
            _shimmeringView.shimmeringOpacity = fmaxf(0.0, fminf(1.0, _panStartValue + progress * 0.5));
            _valueLabel.text = [NSString stringWithFormat:@"Opacity\n%.2f", _shimmeringView.shimmeringOpacity];
        }
    } else if (panRecognizer.state == UIGestureRecognizerStateEnded ||
               panRecognizer.state == UIGestureRecognizerStateCancelled) {
        [self _animateValueLabelVisible:NO];
    }
}

- (void)_animateValueLabelVisible:(BOOL)visible
{
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    void (^animations)() = ^{
        _valueLabel.alpha = (visible ? 1.0 : 0.0);
    };
    [UIView animateWithDuration:0.5 delay:0.0 options:options animations:animations completion:NULL];
}

@end