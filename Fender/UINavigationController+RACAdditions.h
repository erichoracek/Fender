//
//  UINavigationController+RACAdditions.h
//  Automatic
//
//  Created by Eric Horacek on 9/22/15.
//  Copyright © 2015 Automatic Labs. All rights reserved.
//

@import ReactiveCocoa;
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (RACAdditions)

/// Completes just before the receiver displays the given view controller.
- (RACSignal *)aut_willShowViewController:(UIViewController *)viewController;

/// Completes when the receiver displays the given view controller.
- (RACSignal *)aut_didShowViewController:(UIViewController *)viewController;

/// Pushes the given view controller onto the receiver's navigation stack,
/// completing when finished.
- (RACSignal *)aut_pushViewController:(UIViewController *)viewController animated:(BOOL)animated;

/// Pops the current top view controller off of the receiver's navigation stack,
/// completing when finished.
- (RACSignal *)aut_popViewControllerAnimated:(BOOL)animated;

/// Pops view controllers off of the receiver's navigation stack until the
/// specified view controller is at the top of the navigation stack, completing
/// when finished.
- (RACSignal *)aut_popToViewController:(UIViewController *)viewController animated:(BOOL)animated;

/// Pops all the view controllers off of the receiver's navigation stack except
/// the root view controller, completing when finished.
- (RACSignal *)aut_popToRootViewControllerAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
