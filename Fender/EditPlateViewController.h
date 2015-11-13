//
//  EditPlateViewController.h
//  Fender
//
//  Created by Eric Horacek on 11/13/15.
//  Copyright © 2015 Automatic Labs. All rights reserved.
//

@import UIKit;

@class Plate;

@interface EditPlateViewController : UIViewController

- (instancetype)initWithPlate:(Plate *)plate;

@property (readonly, nonatomic, strong) Plate *plate;

@property (readonly, nonatomic, strong) RACSignal *didSubmit;

@end
