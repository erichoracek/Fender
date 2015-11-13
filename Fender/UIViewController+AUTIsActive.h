//
//  UIViewController+AUTIsActive.h
//  Automatic
//
//  Created by Eric Horacek on 6/22/15.
//  Copyright (c) 2015 Automatic Labs. All rights reserved.
//

@import UIKit;
@import ReactiveCocoa;

@interface UIViewController (AUTIsActive)

/// A signal that sends NO upon subscription, and then sends YES or NO when the
/// view controller's view did appear or will disappear, respectively.
- (RACSignal *)aut_isActive;

@end
