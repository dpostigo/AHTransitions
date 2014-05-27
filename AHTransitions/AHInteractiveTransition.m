//
//  AHDynamicInteractiveTransition.m
//  Cards
//
//  Created by Hanssen, Alfie on 3/26/14.
//  Copyright (c) 2014 Alfred Hanssen. All rights reserved.
//

#import "AHInteractiveTransition.h"
#import "AHTransitionUtilities.h"

static const CGFloat AnimationDuration = 0.35f;
static const CGFloat Damping = 0.75f;

@interface AHInteractiveTransition () <UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning>

@property(nonatomic, strong) id <UIViewControllerContextTransitioning> transitionContext;
@property(nonatomic, weak) UIViewController *viewController;
@property(nonatomic, assign, getter = isInteractive) BOOL interactive;
@property(nonatomic, assign, getter = isPresenting) BOOL presenting;
@property(nonatomic, assign) CGFloat lastPercentComplete; // We shouldn't need this, but self.percentComplete is always 0 [AH]

@end

@implementation AHInteractiveTransition

- (instancetype) initWithViewController: (UIViewController *) viewController {
    self = [super init];
    if (self) {
        _viewController = viewController;
    }

    return self;
}

#pragma mark - Transitioning Delegate

- (id <UIViewControllerAnimatedTransitioning>) animationControllerForPresentedController: (UIViewController *) presented presentingController: (UIViewController *) presenting sourceController: (UIViewController *) source {
    self.presenting = YES;

    return self;
}

- (id <UIViewControllerAnimatedTransitioning>) animationControllerForDismissedController: (UIViewController *) dismissed {
    self.presenting = NO;

    return self;
}

- (id <UIViewControllerInteractiveTransitioning>) interactionControllerForPresentation: (id <UIViewControllerAnimatedTransitioning>) animator {
    if (self.isInteractive) {
        return self;
    }

    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>) interactionControllerForDismissal: (id <UIViewControllerAnimatedTransitioning>) animator {
    if (self.isInteractive) {
        return self;
    }

    return nil;
}

#pragma mark - Animated Transitioning

- (NSTimeInterval) transitionDuration: (id <UIViewControllerContextTransitioning>) transitionContext {
    return AnimationDuration;
}

- (void) animateTransition: (id <UIViewControllerContextTransitioning>) transitionContext {
    self.transitionContext = transitionContext;

    UIViewController *fromViewController = [transitionContext viewControllerForKey: UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey: UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];

    if (self.isPresenting) {
        toViewController.view.frame = [AHTransitionUtilities rectForDismissedState: transitionContext forPresentation: self.isPresenting];
        [containerView addSubview: toViewController.view];

        [UIView animateWithDuration: [self transitionDuration: transitionContext] delay: 0.0f usingSpringWithDamping: Damping initialSpringVelocity: 1.0f options: UIViewAnimationOptionBeginFromCurrentState animations: ^{

            fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
            toViewController.view.frame = [AHTransitionUtilities rectForPresentedState: transitionContext forPresentation: self.isPresenting];

        }                completion: ^(BOOL finished) {

            [transitionContext completeTransition: ![transitionContext transitionWasCancelled]];

        }];
    }
    else {
        [UIView animateWithDuration: [self transitionDuration: transitionContext] delay: 0.0f usingSpringWithDamping: Damping initialSpringVelocity: 1.0f options: UIViewAnimationOptionBeginFromCurrentState animations: ^{

            toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
            fromViewController.view.frame = [AHTransitionUtilities rectForDismissedState: transitionContext forPresentation: self.isPresenting];

        }                completion: ^(BOOL finished) {

            [transitionContext completeTransition: ![transitionContext transitionWasCancelled]];
            [fromViewController.view.superview removeFromSuperview];

        }];
    }
}

- (void) animationEnded: (BOOL) transitionCompleted {
    id <UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    UIViewController *fromViewController = [transitionContext viewControllerForKey: UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey: UITransitionContextToViewControllerKey];

    // TODO: Figure out if userInteractionEnabled should be used
    fromViewController.view.userInteractionEnabled = YES;
    toViewController.view.userInteractionEnabled = YES;

    self.interactive = NO;
    self.presenting = NO;
    self.transitionContext = nil;
}

#pragma mark - UIDynamicAnimatorDelegate Methods

- (void) dynamicAnimatorDidPause: (UIDynamicAnimator *) animator {
    [self.transitionContext completeTransition: ![self.transitionContext transitionWasCancelled]];
}

#pragma mark - Interactive Transitioning

- (CGFloat) completionSpeed {
    return [self transitionDuration: self.transitionContext] * (1.0f - self.lastPercentComplete);
}

- (void) startInteractiveTransition: (id <UIViewControllerContextTransitioning>) transitionContext {
    self.transitionContext = transitionContext;
}

#pragma mark - Percent Driven Gesture

- (void) didPan: (UIPanGestureRecognizer *) recognizer {
    CGPoint translation = [recognizer translationInView: recognizer.view];
    CGPoint velocity = [recognizer velocityInView: recognizer.view];

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.interactive = YES;
        [self.viewController dismissViewControllerAnimated: YES completion: nil];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat percent = translation.y / recognizer.view.bounds.size.height;
        percent = fminf(1.0f, percent); // Clamp values in the event of fast pan
        [self updateInteractiveTransition: percent];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (velocity.y > 0) {
            [self finishInteractiveTransition];
        }
        else {
            [self cancelInteractiveTransition];
        }
    }
}

- (void) updateInteractiveTransition: (CGFloat) percentComplete {
    self.lastPercentComplete = percentComplete;

    id <UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    UIViewController *fromViewController = [transitionContext viewControllerForKey: UITransitionContextFromViewControllerKey];

    fromViewController.view.frame = [AHTransitionUtilities rectForPresentedState: transitionContext percentComplete: percentComplete forPresentation: self.isPresenting];
}

- (void) finishInteractiveTransition {
    id <UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    UIViewController *fromViewController = [transitionContext viewControllerForKey: UITransitionContextFromViewControllerKey];

    UIViewController *toViewController = [transitionContext viewControllerForKey: UITransitionContextToViewControllerKey];
    toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
    // TODO: figure out if tintAdjustmentMode should be used

    [UIView animateWithDuration: [self transitionDuration: transitionContext] delay: 0.0f usingSpringWithDamping: Damping initialSpringVelocity: 1.0f options: UIViewAnimationOptionBeginFromCurrentState animations: ^{

        fromViewController.view.frame = [AHTransitionUtilities rectForDismissedState: transitionContext forPresentation: self.isPresenting];

    }                completion: ^(BOOL finished) {

        [transitionContext completeTransition: YES];

    }];
}

- (void) cancelInteractiveTransition {
    id <UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    UIViewController *fromViewController = [transitionContext viewControllerForKey: UITransitionContextFromViewControllerKey];

    [UIView animateWithDuration: [self transitionDuration: transitionContext] delay: 0.0f usingSpringWithDamping: Damping initialSpringVelocity: 1.0f options: UIViewAnimationOptionBeginFromCurrentState animations: ^{

        fromViewController.view.frame = [AHTransitionUtilities rectForPresentedState: transitionContext forPresentation: self.isPresenting];

    }                completion: ^(BOOL finished) {

        [transitionContext completeTransition: NO];

    }];
}

@end
