//
//  Plate_Private.h
//  Fender
//
//  Created by Eric Horacek on 11/13/15.
//  Copyright © 2015 Automatic Labs. All rights reserved.
//

#import "Plate.h"

#include <openalpr/alpr.h>

@interface Plate ()

- (instancetype)initWithAlprPlateResult:(alpr::AlprPlateResult *)plateResult inputImage:(UIImage *)inputImage;

@end
