//
//  Plate.h
//  AlprSample
//
//  Created by Alex on 04/11/15.
//  Copyright © 2015 alpr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface Plate : NSObject

@property (readonly, nonatomic, copy, nullable) NSString *number;
@property (readonly, nonatomic, copy, nullable) NSNumber *confidence;
@property (readonly, nonatomic, copy, nullable) UIBezierPath *path;
@property (readonly, nonatomic, strong, nullable) UIImage *input;

@end
