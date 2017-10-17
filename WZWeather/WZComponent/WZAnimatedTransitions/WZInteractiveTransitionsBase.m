//
//  WZInteractiveTransitionsBase.m
//  WZWeather
//
//  Created by wizet on 17/6/20.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZInteractiveTransitionsBase.h"

@interface WZInteractiveTransitionsBase()

@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;

@end

@implementation WZInteractiveTransitionsBase


#pragma mark - 
- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    self.transitionContext = transitionContext;
    [super startInteractiveTransition:transitionContext];
}

#pragma mark - Accessor
- (void)setGesture:(UIScreenEdgePanGestureRecognizer *)gesture {
    _gesture = gesture;
    //配置交互手势
    [_gesture addTarget:self action:@selector(gestureRecognizeDidUpdate:)];
}

- (void)gestureRecognizeDidUpdate:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer
{
    NSLog(@"%s---%@", __func__, self.transitionContext);
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
            // The Began state is handled by the view controllers.  In response
            // to the gesture recognizer transitioning to this state, they
            // will trigger the presentation or dismissal.
            break;
        case UIGestureRecognizerStateChanged:
            // We have been dragging! Update the transition context accordingly.
            
            
            [self updateInteractiveTransition:[self percentForGesture:gestureRecognizer]];
        
            break;
        case UIGestureRecognizerStateEnded:
            // Dragging has finished.
            // Complete or cancel, depending on how far we've dragged.
            if ([self percentForGesture:gestureRecognizer] >= 0.5f)
                [self finishInteractiveTransition];
            else
                [self cancelInteractiveTransition];
            break;
        default:
            // Something happened. cancel the transition.
            [self cancelInteractiveTransition];
            break;
    }
}

- (CGFloat)percentForGesture:(UIScreenEdgePanGestureRecognizer *)gesture
{
    // Because view controllers will be sliding on and off screen as part
    // of the animation, we want to base our calculations in the coordinate
    // space of the view that will not be moving: the containerView of the
    // transition context.
    UIView *transitionContainerView = self.transitionContext.containerView;
    
    CGPoint locationInSourceView = [gesture locationInView:transitionContainerView];
    
    // Figure out what percentage we've gone.
    
    CGFloat width = CGRectGetWidth(transitionContainerView.bounds);
    CGFloat height = CGRectGetHeight(transitionContainerView.bounds);
    
    // Return an appropriate percentage based on which edge we're dragging
    // from.
//    if (self.edge == UIRectEdgeRight)
//        return (width - locationInSourceView.x) / width;
//    else if (self.edge == UIRectEdgeLeft)
    return locationInSourceView.x / width;
//    else if (self.edge == UIRectEdgeBottom)
//        return (height - locationInSourceView.y) / height;
//    else if (self.edge == UIRectEdgeTop)
//        return locationInSourceView.y / height;
//    else
//        return 0.f;
}

- (void)dealloc {
    if ([self respondsToSelector:@selector(gestureRecognizeDidUpdate:)]) {
        [self.gesture removeTarget:self action:@selector(gestureRecognizeDidUpdate:)];
        NSLog(@"%@", self.gesture);
        NSLog(@"--------------------------------------------------------------------------%s", __func__);
    }
    
}
@end
