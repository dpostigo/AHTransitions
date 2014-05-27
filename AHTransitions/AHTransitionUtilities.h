//
//  InteractiveTransitionUtilities.h
//  Cards
//
//  Created by Hanssen, Alfie on 3/28/14.
//  Copyright (c) 2014 Alfred Hanssen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AHTransitionUtilities : NSObject

// Frames

+ (CGRect) rectForDismissedState: (id <UIViewControllerContextTransitioning>) transitionContext forPresentation: (BOOL) isPresentation;

+ (CGRect) rectForPresentedState: (id <UIViewControllerContextTransitioning>) transitionContext forPresentation: (BOOL) isPresentation;

+ (CGRect) rectForPresentedState: (id <UIViewControllerContextTransitioning>) transitionContext percentComplete: (CGFloat) percentComplete forPresentation: (BOOL) isPresentation;

// Dynamics

+ (UIEdgeInsets) collisionInsets: (id <UIViewControllerContextTransitioning>) transitionContext forPresentation: (BOOL) isPresentation;

+ (UIEdgeInsets) collisionInsetsForPresentation: (id <UIViewControllerContextTransitioning>) transitionContext;

+ (UIEdgeInsets) collisionInsetsForDismissal: (id <UIViewControllerContextTransitioning>) transitionContext;

+ (CGVector) gravityVector: (id <UIViewControllerContextTransitioning>) transitionContext forPresentation: (BOOL) isPresentation;

+ (CGVector) gravityVectorForPresentation: (id <UIViewControllerContextTransitioning>) transitionContext;

+ (CGVector) gravityVectorForDismissal: (id <UIViewControllerContextTransitioning>) transitionContext;

@end
