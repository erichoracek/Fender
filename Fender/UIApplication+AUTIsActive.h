//
//  UIApplication+AUTIsActive.h
//  Automatic
//
//  Created by Eric Horacek on 6/22/15.
//  Copyright (c) 2015 Automatic Labs. All rights reserved.
//

@import UIKit;
@import ReactiveCocoa;

@interface UIApplication (AUTIsActive)

/// A signal that sends whether YES or NO depending on if this application is
/// currently active upon subscription, and then sends YES or NO when the
/// application becomes active or resigns active, respectively.
- (RACSignal *)aut_isActive;

@end
