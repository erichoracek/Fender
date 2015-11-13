//
//  AFNetworkReachabilityManager+AUTReactiveAdditions.h
//  AUTAPIClient
//
//  Created by Eric Horacek on 7/24/15.
//  Copyright (c) 2015 Automatic Labs. All rights reserved.
//

@import AFNetworking;
@import ReactiveCocoa;

NS_ASSUME_NONNULL_BEGIN

@interface AFNetworkReachabilityManager (AUTReactiveAdditions)

/// Returns a signal that sends updates to the reachability of the specified
/// domain as NSNumber<AFNetworkReachabilityStatus>.
///
/// Does not error or complete.
///
/// Filters AFNetworkReachabilityStatusUnknown, sending next only when the
/// reachability status has been determined.
+ (RACSignal *)aut_reachabilityStatusForDomain:(NSString *)domain;

@end

NS_ASSUME_NONNULL_END
