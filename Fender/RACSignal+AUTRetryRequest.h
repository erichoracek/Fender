//
//  RACSignal+AUTRetryRequest.h
//  AUTAPIClient
//
//  Created by Eric Horacek on 11/6/15.
//  Copyright © 2015 Automatic Labs. All rights reserved.
//

@import ReactiveCocoa;

NS_ASSUME_NONNULL_BEGIN

/// Provides a mechanism for consumers to specify whether an error should be
/// eligible for a retry.
///
/// Returns YES for errors in the AFURLResponseSerializationErrorDomain only.
typedef BOOL (^AUTIsErrorRecoverableBlock)(NSError *error);

/// The default implementation of AUTIsErrorRecoverableBlock used when none is
/// specified.
extern AUTIsErrorRecoverableBlock AUTDefaultIsErrorRecoverable;

/// Returns the back-off interval for a retry, given the number of times that a
/// request has already been performed.
///
/// Starts at ~1 second for 0 retries and caps at ~60 seconds for 4+ retries.
extern NSTimeInterval AUTRetryBackOffInterval(NSUInteger retryCount);

/// Provides a chainable syntax for retrying URL requests with an exponential
/// back-off and based on the reachability of the host that they are against.
@interface RACSignal (AUTRetryRequest)

/// Invokes aut_retryForReachability:isErrorRecoverable: with a default
/// isErrorRecoverable block returning YES for errors in the
/// AFURLResponseSerializationErrorDomain only.
- (instancetype)aut_retryForReachability:(RACSignal *)reachability;

/// Performs the request represented by the receiver when the given reachability
/// signal sends a value that isn't AFNetworkReachabilityStatusNotReachable.
///
/// Once reachability is established, subscribes to the receiver, retrying upon
/// recoverable errors as established by the isErrorRecoverable signal. Once the
/// receiver completes, sends a next value, or errors unrecoverably, the
/// returned signal sends the same event.
///
/// @param reachability A signal that sends AFNetworkReachabilityStatus values
///        wrapped within an NSNumber indicating whether the receiver can be
///        retried. Should not send AFNetworkReachabilityStatusUnknown, error,
///        or complete.
///
/// @param isErrorRecoverable A block to allow consumers to specify whether an
///        error that the receiver emitted is eligible for retry.
///
/// @return A cold signal that will send next and complete values passed-through
///         from the receiver once it was successful, otherwise errors if
///         isErrorRecoverable returns NO for an error that occurs.
- (instancetype)aut_retryForReachability:(RACSignal *)reachability isErrorRecoverable:(AUTIsErrorRecoverableBlock)isErrorRecoverable;

/// Invokes aut_retryForReachability: with the reachability of the provided
/// host.
- (instancetype)aut_retryForHost:(NSString *)host;

/// Invokes aut_retryForReachability:isErrorRecoverable: with the reachability
/// of the provided host and the provided isErrorRecoverable block.
- (instancetype)aut_retryForHost:(NSString *)host isErrorRecoverable:(AUTIsErrorRecoverableBlock)isErrorRecoverable;

@end

NS_ASSUME_NONNULL_END
