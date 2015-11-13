//
//  PlateScanner.m
//  AlprSample
//
//  Created by Alex on 04/11/15.
//  Copyright © 2015 alpr. All rights reserved.
//

#import "PlateScanner.h"
#import "Plate_Private.h"
#import "UIImage+CVMat.h"

#ifdef __cplusplus
#include "opencv2/highgui/highgui.hpp"
#import <opencv2/videoio/cap_ios.h>
using namespace cv;
#endif

#import <openalpr/alpr.h>

@interface PlateScanResults ()

- (instancetype)initWithAlprResults:(alpr::AlprResults *)results inputImage:(UIImage *)inputImage;

@end

@implementation PlateScanner {
    alpr::Alpr* delegate;
}

- (instancetype)init {
    self = [super init];

    delegate = new alpr::Alpr(
        [@"us" UTF8String],
        [NSBundle.mainBundle pathForResource:@"openalpr.conf" ofType:nil].UTF8String,
        [NSBundle.mainBundle pathForResource:@"runtime_data" ofType:nil].UTF8String
    );

    delegate->setTopN(3);
    
    if (delegate->isLoaded() == false) {
        NSLog(@"Error initializing OpenALPR library");
        delegate = nil;
    }

    if (delegate == NULL) return nil;

    return self;
}

- (BOOL)isDelegateLoaded:(NSError **)error {
    if (delegate->isLoaded() == false) {
        *error = [NSError errorWithDomain:@"alpr" code:-100 userInfo:@{
            NSLocalizedDescriptionKey: @"Error loading OpenALPR"
        }];
        return NO;
    }
    return YES;
}

- (RACSignal *)scanPlatesFromImage:(UIImage *)image {
    NSParameterAssert(image != nil);

    return [[RACSignal defer:^{
        NSError *error;
        if (![self isDelegateLoaded:&error]) return [RACSignal error:error];

        cv::Mat colorImage = [image asCVMat];

        std::vector<alpr::AlprRegionOfInterest> regionsOfInterest;
        alpr::AlprResults results = delegate->recognize(
            colorImage.data,
            (int)colorImage.elemSize(),
            colorImage.cols,
            colorImage.rows,
            regionsOfInterest);

        PlateScanResults *plateScanResults = [[PlateScanResults alloc] initWithAlprResults:&results inputImage:image];
        return [RACSignal return:plateScanResults];
    }] subscribeOn:[RACScheduler scheduler]];
}

@end

@implementation PlateScanResults

- (instancetype)initWithAlprResults:(alpr::AlprResults *)results inputImage:(UIImage *)inputImage {
    self = [super init];

    NSMutableArray *bestPlates = [NSMutableArray array];
    for (int i = 0; i < results->plates.size(); i++) {
        alpr::AlprPlateResult plateResult = results->plates[i];
        Plate *plate = [[Plate alloc] initWithAlprPlateResult:&plateResult inputImage:inputImage];
        [bestPlates addObject:plate];
    }
    _plates = [bestPlates copy];

    CGSize size = CGSizeMake(results->img_width, results->img_height);
    _imageRect = (CGRect){ .size = size };

    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p> { plates: %@, imageRect %@ }", self.class, self, self.plates, NSStringFromCGRect(self.imageRect)];
}


@end
