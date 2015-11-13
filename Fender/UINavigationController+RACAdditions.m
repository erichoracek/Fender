//
//  UINavigationController+RACAdditions.m
//  Automatic
//
//  Created by Eric Horacek on 9/22/15.
//  Copyright © 2015 Automatic Labs. All rights reserved.
//

#import <objc/runtime.h>

#import "UINavigationController+RACAdditions.h"

NS_ASSUME_NONNULL_BEGIN

/// Acts a a proxy for the navigation controller delegate when none has been set.
@interface UINavigationControllerDelegateProxy: NSObject <UINavigationControllerDelegate>

@end

@implementation UINavigationController (RACAdditions)

#pragma mark - Public

- (RACSignal *)aut_willShowViewController:(UIViewController *)viewController {
    NSParameterAssert(viewController != nil);

    return [[[[[[[self aut_delegates]
        map:^(id delegate) {
            return [delegate
                rac_signalForSelector:@selector(navigationController:willShowViewController:animated:)
                fromProtocol:@protocol(UINavigationControllerDelegate)];
        }]
        switchToLatest]
        reduceEach:^(id navigationController, UIViewController *shownViewController, id animated) {
            return shownViewController;
        }]
        filter:^ BOOL (UIViewController *shownViewController) {
            return shownViewController == viewController;
        }]
        take:1]
        ignoreValues];
}

- (RACSignal *)aut_didShowViewController:(UIViewController *)viewController {
    NSParameterAssert(viewController != nil);

    return [[[[[[[self aut_delegates]
        map:^(id delegate) {
            return [delegate
                rac_signalForSelector:@selector(navigationController:didShowViewController:animated:)
                fromProtocol:@protocol(UINavigationControllerDelegate)];
        }]
        switchToLatest]
        reduceEach:^(id navigationController, UIViewController *shownViewController, id animated) {
            return shownViewController;
        }]
        filter:^ BOOL (UIViewController *shownViewController) {
            return shownViewController == viewController;
        }]
        take:1]
        ignoreValues];
}

- (RACSignal *)aut_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSParameterAssert(viewController != nil);

    return [RACSignal defer:^{
        [self pushViewController:viewController animated:animated];

        if (!animated) return [RACSignal empty];

        return [self aut_didShowViewController:viewController];
    }];
}

- (RACSignal *)aut_popViewControllerAnimated:(BOOL)animated {
    return [RACSignal defer:^{
        [self popViewControllerAnimated:animated];

        if (!animated) return [RACSignal empty];

        return [self aut_didShowViewController:self.viewControllers.lastObject];
    }];
}

- (RACSignal *)aut_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSParameterAssert(viewController != nil);
    
    return [RACSignal defer:^{
        if (self.viewControllers.lastObject == viewController) return [RACSignal empty];

        [self popToViewController:viewController animated:animated];

        if (!animated) return [RACSignal empty];

        return [self aut_didShowViewController:viewController];
    }];
}

- (RACSignal *)aut_popToRootViewControllerAnimated:(BOOL)animated {
    return [RACSignal defer:^{
        if (self.viewControllers.count <= 1) return [RACSignal empty];

        UIViewController *rootViewController = self.viewControllers.firstObject;

        [self popToRootViewControllerAnimated:animated];

        if (!animated) return [RACSignal empty];

        return [self aut_didShowViewController:rootViewController];
    }];
}

#pragma mark - Private

/// Sends changes to the receiver's delegate, optionally creating a proxy
/// delegate if one has not been set yet.
- (RACSignal *)aut_delegates {
    return [RACSignal defer:^{
        if (self.delegate == nil) {
            self.aut_navigationControllerDelegateProxy = [[UINavigationControllerDelegateProxy alloc] init];
            self.delegate = self.aut_navigationControllerDelegateProxy;
        }

        return RACObserve(self, delegate);
    }];
}

- (UINavigationControllerDelegateProxy *)aut_navigationControllerDelegateProxy {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAut_navigationControllerDelegateProxy:(UINavigationControllerDelegateProxy *)delegateProxy {
    objc_setAssociatedObject(self, @selector(aut_navigationControllerDelegateProxy), delegateProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UINavigationControllerDelegateProxy

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {}

@end

NS_ASSUME_NONNULL_END
