//
//  RHCAnimation.m
//  Block
//
//  Created by hairong chen on 16/9/4.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#import "RHCAnimation.h"

@interface RHCAnimation ()

@end

@implementation RHCAnimation
/*
- (void)GCC  {
    self.navigationItem.titleView = ({
        UILabel *titleLabel = [[UILabel alloc]init];
        titleLabel.text = @"大厅";
        [titleLabel sizeToFit];
        titleLabel;
    });
    
    
    self.navigationItem.rightBarButtonItem = ({
        
        UIBarButtonItem *btnItem = [[UIBarButtonItem alloc]init];
        btnItem.title = @"直播";
        btnItem.target = self;
        btnItem.action = @selector(onPressedBeginBrodcastButton:);
        btnItem;
    });
}


- (void)onPressedBeginBrodcastButton:(id)sender {}
*/

/*
 // sharkAnim 晃动
 - (void)longPress:(UILongPressGestureRecognizer *)sender {
 if (sender.state != UIGestureRecognizerStateRecognized) { return;}
 
 /*
 if (self.pathView.layer.speed == 1.0) {
 [self pauseAnim];
 }else {
 [self resumeAnim];
 }
 */


//
//if (!self.sharkAnim) {
//    self.sharkAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
//    [self.sharkAnim setDuration:0.3];
//    
//    CGFloat angle = M_PI_4 / 15.0;
//    
//    NSArray *angles = @[@0.0,@(-angle),@0.0,@(angle),@(0.0)];
//    
//    [self.sharkAnim setValues:angles];
//    [self.sharkAnim setRepeatCount:HUGE_VALF];
//    
//    [self.pathView.layer addAnimation:self.sharkAnim forKey:@"sharkAnim"];
//}else {
//    [self.pathView.layer removeAnimationForKey:@"sharkAnim"];
//    self.sharkAnim = nil;
//}
//}
//
///**
// *  关键帧动画
// *
// *  @return
// */
//
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = [touches anyObject];
//    CGPoint location = [touch locationInView:self.view];
//    
//    // create keyFrameAnimation
//    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
//    [anim setDuration:0.5];
//    // 设置每个帧的值
//    NSArray *values = @[[NSValue valueWithCGPoint:self.pathView.layer.position],
//                        [NSValue valueWithCGPoint:location],
//                        [NSValue valueWithCGPoint:self.view.center]];
//    
//    [anim setValues:values];
//    // 让动画停留在结束的位置
//    anim.removedOnCompletion = NO;
//    anim.fillMode = kCAFillModeForwards;
//    anim.delegate = self; // 设置代理
//    
//    [self.pathView.layer addAnimation:anim forKey:nil];
//}
//
///**
// *  /
// *
// *  @param anim 基本动画
// */
//- (void)addAnimation {
//    CGPoint location ;//[id locationInView:self.view];
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
//    [animation setDuration:0.5];
//    animation.fromValue = [NSValue valueWithCGPoint:self.pathView.layer.position];
//    animation.toValue = [NSValue valueWithCGPoint:location];
//    // 让动画停留在结束的位置
//    animation.removedOnCompletion = NO;
//    animation.fillMode = kCAFillModeForwards;
//    animation.delegate = self; // 设置代理
//    // 将结束点的位置保存在动画对象中
//    [animation setValue:[NSValue valueWithCGPoint:location ] forKey:@"tagetPoint"];
//    [animation setValue:@"position" forKey:@"AnimationType"];
//    
//    // 添加动画到相应层
//    [self.pathView.layer addAnimation:animation forKey:@"positionAnim"];
//}
//
//
//- (void)animationDidStart:(CAAnimation *)anim {
//    NSLog(@"%@",NSStringFromCGPoint(self.pathView.layer.position));
//}
//
//- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
//    
//    // 把动画对象中目标点的值取出来
//    CGPoint tagetPoint = [[anim valueForKey:@"tagetPoint"]CGPointValue];
//    // 关闭隐式动画，并设置layer新的positon
//    [CATransaction begin];
//    [CATransaction setDisableActions:YES];
//    self.pathView.layer.position = tagetPoint;
//    [CATransaction commit];
//}
//
//- (void)resumeAnim {
//    CFTimeInterval pauseTime = pauseTime = self.pathView.layer.timeOffset;
//    self.pathView.layer.timeOffset = 0.0;
//    self.pathView.layer.speed = 1.0;
//    
//    CFTimeInterval timeSincePause =  [self.pathView.layer convertTime:CACurrentMediaTime() toLayer:nil] - pauseTime;
//    
//    self.pathView.layer.beginTime = timeSincePause;
//}
//
//- (void)pauseAnim {
//    CFTimeInterval pausedTime = [self.pathView.layer convertTime:CACurrentMediaTime() toLayer:nil];
//    // 让CALayer 的时间停止走动
//    self.pathView.layer.speed = 0.0;
//    // 让CALayer 的时间停留在pausedTime这个时刻
//    self.pathView.layer.timeOffset = pausedTime;
//}
//
//

@end
