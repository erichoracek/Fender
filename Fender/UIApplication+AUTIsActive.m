//
//  UIApplication+AUTIsActive.m
//  Automatic
//
//  Created by Eric Horacek on 6/22/15.
//  Copyright (c) 2015 Automatic Labs. All rights reserved.
//

#import "UIApplication+AUTIsActive.h"

@implementation UIApplication (AUTIsActive)

- (RACSignal *)aut_isActive {
    RACSignal *activeChanged = [RACSignal merge:@[
        [[NSNotificationCenter.defaultCenter rac_addObserverForName:UIApplicationDidBecomeActiveNotification object:nil] mapReplace:@YES],
        [[NSNotificationCenter.defaultCenter rac_addObserverForName:UIApplicationWillResignActiveNotification object:nil] mapReplace:@NO],
    ]];

    @weakify(self);
    RACSignal *currentActive = [RACSignal defer:^RACSignal *{
        @strongify(self);

        return [RACSignal return:@(self.applicationState == UIApplicationStateActive)];
    }];

    return [[currentActive concat:activeChanged]
        distinctUntilChanged];
}

@end
