//
//  UIImageCVMatConverter.h
//  OpenCViOS
//
//  Created by CHARU HANS on 6/6/12.
//  Copyright (c) 2012 University of Houston - Main Campus. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef __cplusplus
#include "opencv2/highgui/highgui.hpp"
#import <opencv2/videoio/cap_ios.h>
using namespace cv;
#endif

@interface UIImage(CVMat)

- (cv::Mat)asCVMat;

@end
