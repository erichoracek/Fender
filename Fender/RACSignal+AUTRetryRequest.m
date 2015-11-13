//
//  RACSignal+AUTRetryRequest.m
//  AUTAPIClient
//
//  Created by Eric Horacek on 11/6/15.
//  Copyright © 2015 Automatic Labs. All rights reserved.
//

#import "AFNetworkReachabilityManager+AUTReactiveAdditions.h"

#import "RACSignal+AUTRetryRequest.h"

NS_ASSUME_NONNULL_BEGIN

AUTIsErrorRecoverableBlock AUTDefaultIsErrorRecoverable = ^(NSError *error){
    // By default, only treat AFURLResponseSerializationErrorDomain
    // errors as recoverable.
    return [error.domain isEqualToString:AFURLResponseSerializationErrorDomain];
};

@implementation RACSignal (AUTRetryRequest)

- (instancetype)aut_retryForReachability:(RACSignal *)reachability {
    NSParameterAssert(reachability != nil);

    return [self aut_retryForReachability:reachability isErrorRecoverable:AUTDefaultIsErrorRecoverable];
}

- (instancetype)aut_retryForReachability:(RACSignal *)reachability isErrorRecoverable:(AUTIsErrorRecoverableBlock)isErrorRecoverable {
    NSParameterAssert(reachability != nil);
    NSParameterAssert(isErrorRecoverable != nil);

    __block NSUInteger retryCount = 0;

    return [[[[[[[reachability
        map:^(NSNumber *status) {
            switch (status.integerValue) {
            case AFNetworkReachabilityStatusNotReachable:
                return [RACSignal empty];
            default:
                return self;
            }
        }]
        // Ensure requests do not overlap.
        concat]
        materialize]
        flattenMap:^(RACEvent *event) {
            // If the event is not an error, immediately forward it.
            if (event.eventType != RACEventTypeError) return [RACSignal return:event];

            NSError *error = event.error;

            // If the error is unrecoverable, immediately forward the error past
            // the below retry to consumers.
            if (!isErrorRecoverable(error)) {
                return [RACSignal return:event];
            }
            
            // Otherwise, dematerialize the error after the back off delay so
            // that it is caught by the retry below.
            return [[[RACSignal return:event]
                delay:AUTRetryBackOffInterval(retryCount++)]
                dematerialize];
        }]
        retry]
        // Take the first RACEvent (completed, error, or next) sent.
        take:1]
        dematerialize];
}

- (instancetype)aut_retryForHost:(NSString *)host {
    return [self aut_retryForHost:host isErrorRecoverable:AUTDefaultIsErrorRecoverable];
}

- (instancetype)aut_retryForHost:(NSString *)host isErrorRecoverable:(AUTIsErrorRecoverableBlock)isErrorRecoverable {
    NSParameterAssert(host != nil);
    NSParameterAssert(isErrorRecoverable != nil);

    RACSignal *reachability = [AFNetworkReachabilityManager aut_reachabilityStatusForDomain:host];

    return [self aut_retryForReachability:reachability isErrorRecoverable:isErrorRecoverable];
}

@end

NSTimeInterval AUTRetryBackOffInterval(NSUInteger retryCount) {
    // Start at e^0 (~1s), and cap at e^4 (~60 seconds).
    double exponent = (double)MIN(retryCount, (NSUInteger)4);

    return exp(exponent);
}

NS_ASSUME_NONNULL_END
