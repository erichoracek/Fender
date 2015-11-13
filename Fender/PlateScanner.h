//
//  PlateScanner.h
//  AlprSample
//
//  Created by Alex on 04/11/15.
//  Copyright © 2015 alpr. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>

@class Plate;

@interface PlateScanner : NSObject

- (RACSignal *)scanPlatesFromImage:(UIImage *)image;

@end

@interface PlateScanResults : NSObject

- (instancetype)init NS_UNAVAILABLE;

@property (readonly, nonatomic, copy) NSArray<Plate *> *plates;

@property (readonly, nonatomic, assign) CGRect imageRect;

@end
