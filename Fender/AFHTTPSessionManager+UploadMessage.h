//
//  AFHTTPSessionManager+UploadMessage.h
//  Fender
//
//  Created by Eric Horacek on 11/13/15.
//  Copyright © 2015 Automatic Labs. All rights reserved.
//

@import ReactiveCocoa;
@import AFNetworking;

@class Plate;

@interface AFHTTPSessionManager (UploadMessage)

- (RACSignal *)uploadMessage:(NSString *)message forPlate:(Plate *)plate;

@end
