//
//  AHDynamicInteractiveTransition.h
//  Cards
//
//  Created by Hanssen, Alfie on 3/26/14.
//  Copyright (c) 2014 Alfred Hanssen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AHInteractiveTransition : UIPercentDrivenInteractiveTransition <UIViewControllerTransitioningDelegate>

- (instancetype) initWithViewController: (UIViewController *) viewController;

- (void) didPan: (UIPanGestureRecognizer *) recognizer;

@end
