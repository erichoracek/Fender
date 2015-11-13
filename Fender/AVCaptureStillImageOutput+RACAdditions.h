//
//  AVCaptureStillImageOutput+RACAdditions.h
//  Fender
//
//  Created by Eric Horacek on 11/13/15.
//  Copyright © 2015 Automatic Labs. All rights reserved.
//

@import ReactiveCocoa;
@import AVFoundation;

@interface AVCaptureStillImageOutput (RACAdditions)

- (RACSignal *)aut_captureImage;

@end
