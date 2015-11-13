//
//  UIViewController+AUTIsActive.m
//  Automatic
//
//  Created by Eric Horacek on 6/22/15.
//  Copyright (c) 2015 Automatic Labs. All rights reserved.
//

#import "UIViewController+AUTIsActive.h"

@implementation UIViewController (AUTIsActive)

- (RACSignal *)aut_isActive {
    RACSignal *appearanceChanged = [RACSignal merge:@[
        [[self rac_signalForSelector:@selector(viewDidAppear:)] mapReplace:@YES],
        [[self rac_signalForSelector:@selector(viewWillDisappear:)] mapReplace:@NO],
    ]];

    // There is no way to tell if a view controller is currently "appeared", so
    // we assume that is isn't at the time of subscription.
    return [[appearanceChanged startWith:@NO]
        distinctUntilChanged];
}

@end
