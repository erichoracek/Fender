//
//  Plate.m
//  AlprSample
//
//  Created by Alex on 04/11/15.
//  Copyright © 2015 alpr. All rights reserved.
//

#import "Plate_Private.h"

@implementation Plate

- (instancetype)initWithAlprPlateResult:(alpr::AlprPlateResult *)plateResult inputImage:(UIImage *)inputImage {
    self = [super init];

    alpr::AlprPlate *plate = &plateResult->bestPlate;

    _number = [NSString stringWithCString:plate->characters.c_str() encoding:NSString.defaultCStringEncoding];
    _confidence = @(plate->overall_confidence);

    CGMutablePathRef path = CGPathCreateMutable();
    for (int pointIndex = 0; pointIndex < 4; pointIndex++) {
        alpr::AlprCoordinate coordinate = plateResult->plate_points[pointIndex];
        CGPoint point = CGPointMake(coordinate.x, coordinate.y);

        if (pointIndex == 0) {
            CGPathMoveToPoint(path, nil, point.x, point.y);
        } else {
            CGPathAddLineToPoint(path, nil, point.x, point.y);
        }
    }
    CGPathCloseSubpath(path);
    _path = [UIBezierPath bezierPathWithCGPath:path];

    // Give the plate input image a bit of an inset in case the plate actually
    // extends further to one side.
    CGFloat inset = (_path.bounds.size.height / 4.0);
    CGImageRef imageRef = CGImageCreateWithImageInRect(inputImage.CGImage, CGRectInset(_path.bounds, -inset, -inset));
    _input = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);

    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p> { number: %@, confidence: %@, path: %@ }", self.class, self, self.number, self.confidence, self.path];
}

@end
