//
//  AFHTTPRequestOperationManager+AUTReactiveCocoaAdditions.m
//  AUTAPIClient
//
//  Created by Robert Böhnke on 24/02/15.
//  Copyright (c) 2015 Automatic Labs. All rights reserved.
//

@import ReactiveCocoa;
@import AFNetworking;

#import "RACSignal+AUTRetryRequest.h"

#import "AFHTTPSessionManager+AUTReactiveCocoaAdditions.h"

NS_ASSUME_NONNULL_BEGIN

@implementation AFHTTPSessionManager (AUTReactiveCocoaAdditions)

- (RACSignal *)aut_enqueueRequest:(NSURLRequest *)request {
    NSParameterAssert(request != nil);

    NSURLRequest *requestCopy = [request copy];

    @weakify(self)
    return [[RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        @strongify(self)

        NSURLSessionDataTask *task = [self dataTaskWithRequest:requestCopy
            completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                if (error == nil) {
                    [subscriber sendNext:responseObject];
                    [subscriber sendCompleted];
                } else {
                    [subscriber sendError:error];
                }
            }];

        self.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

        [task resume];

        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }] setNameWithFormat:@"%@ aut_enqueueRequest: %@", self, requestCopy];
}

- (RACSignal *)aut_enqueueRetryingRequest:(NSURLRequest *)request isErrorRecoverable:(AUTIsErrorRecoverableBlock)isErrorRecoverable {
    NSParameterAssert(request != nil);
    NSParameterAssert(isErrorRecoverable != nil);

    return [[self aut_enqueueRequest:request]
        aut_retryForHost:request.URL.host isErrorRecoverable:isErrorRecoverable];
}

- (RACSignal *)aut_enqueueRetryingRequest:(NSURLRequest *)request {
    NSParameterAssert(request != nil);

    return [[self aut_enqueueRequest:request]
        aut_retryForHost:request.URL.host];
}

@end

NS_ASSUME_NONNULL_END
