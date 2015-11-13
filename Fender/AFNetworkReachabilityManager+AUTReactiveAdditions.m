//
//  AFNetworkReachabilityManager+AUTReactiveAdditions.m
//  AUTAPIClient
//
//  Created by Eric Horacek on 7/24/15.
//  Copyright (c) 2015 Automatic Labs. All rights reserved.
//

#import "AFNetworkReachabilityManager+AUTReactiveAdditions.h"

NS_ASSUME_NONNULL_BEGIN

@implementation AFNetworkReachabilityManager (AUTReactiveAdditions)

+ (RACSignal *)aut_reachabilityStatusForDomain:(NSString *)domain {
    NSParameterAssert(domain != nil);

    return [[RACSignal
        createSignal:^(id<RACSubscriber> subscriber) {
            AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager managerForDomain:domain];
            [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
                [subscriber sendNext:@(status)];
            }];

            [manager startMonitoring];

            return [RACDisposable disposableWithBlock:^{
                [manager stopMonitoring];
            }];
        }]
        filter:^ BOOL (NSNumber *status) {
            return status.integerValue != AFNetworkReachabilityStatusUnknown;
        }];
}

@end

NS_ASSUME_NONNULL_END
