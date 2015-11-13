//
//  AFHTTPSessionManager+UploadMessage.m
//  Fender
//
//  Created by Eric Horacek on 11/13/15.
//  Copyright © 2015 Automatic Labs. All rights reserved.
//

#import "Plate.h"

#import "AFHTTPSessionManager+AUTReactiveCocoaAdditions.h"

#import "AFHTTPSessionManager+UploadMessage.h"

@implementation AFHTTPSessionManager (UploadMessage)

- (RACSignal *)uploadMessage:(NSString *)message forPlate:(Plate *)plate {
    return [RACSignal defer:^{
        NSString *path = [NSString stringWithFormat:@"/California/%@", plate.number];

        NSError *error;
        NSURLRequest *request = [self.requestSerializer
            requestWithMethod:@"POST"
            URLString:[NSURL URLWithString:path relativeToURL:self.baseURL].absoluteString
            parameters:@{ @"message": message }
            error:&error];
        if (request == nil) return [RACSignal error:error];

        return [self aut_enqueueRequest:request];
    }];
}

@end
