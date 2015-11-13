//
//  ViewController.m
//  Fender
//
//  Created by Eric Horacek on 11/13/15.
//  Copyright © 2015 Automatic Labs. All rights reserved.
//

@import AVFoundation;
@import ReactiveCocoa;
@import QuartzCore;
@import CoreText;

#import "UIViewController+AUTIsActive.h"
#import "UIApplication+AUTIsActive.h"

#import "Plate.h"
#import "AVCaptureStillImageOutput+RACAdditions.h"
#import "PlateScanner.h"
#import "EditPlateViewController.h"
#import "UINavigationController+RACAdditions.h"

#import "ScanPlateViewController.h"

@interface PlateDisplay : NSObject

- (instancetype)initWithPlate:(Plate *)plate numberLayer:(CATextLayer *)numberLayer outlineLayer:(CAShapeLayer *)outlineLayer;

@property (readonly, nonatomic, strong) Plate *plate;
@property (readonly, nonatomic, strong) CATextLayer *numberLayer;
@property (readonly, nonatomic, strong) CAShapeLayer *outlineLayer;

@end

@interface ScanPlateViewController ()

@property (readonly, nonatomic, strong) PlateScanner *plateScanner;
@property AVCaptureSession *session;
@property AVCaptureStillImageOutput *output;
@property AVCaptureVideoPreviewLayer *previewLayer;
@property AVCaptureConnection *connection;
@property (readonly, nonatomic, strong) RACSubject *platesToEdit;

@property (readwrite, nonatomic, copy) NSArray<PlateDisplay *> *displayedPlates;

@end

@implementation ScanPlateViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nil bundle:nil];

    self.navigationItem.title = @"Fender";

    _platesToEdit = [RACSubject subject];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Enter manually" style:UIBarButtonItemStyleDone target:nil action:NULL];
    self.navigationItem.rightBarButtonItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal return:[[Plate alloc] init]];
    }];
    [[self.navigationItem.rightBarButtonItem.rac_command.executionSignals concat] subscribe:self.platesToEdit];

    _plateScanner = [[PlateScanner alloc] init];

    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (input == nil) {
        NSLog(@"error creating AVCaptureDeviceInput: %@", error);
    } else {
        _output = [[AVCaptureStillImageOutput alloc] init];

        _session = [AVCaptureSession new];
        [_session addOutput:_output];
        [_session addInput:input];

        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
        [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];

        _connection = _previewLayer.connection;
        _connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }

    _displayedPlates = [NSArray array];

    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.session startRunning];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.previewLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.previewLayer];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    [self.view addGestureRecognizer:tapGestureRecognizer];

    RACSignal *tappedPlates = [[[tapGestureRecognizer rac_gestureSignal]
        map:^ id (UITapGestureRecognizer *gesture) {
            CGPoint point = [gesture locationInView:gesture.view];

            for (PlateDisplay *plateDisplay in self.displayedPlates) {
                if (CGRectContainsPoint(plateDisplay.numberLayer.frame, point)) {
                    return plateDisplay.plate;
                }
                UIBezierPath *outlinePath = [UIBezierPath bezierPathWithCGPath:plateDisplay.outlineLayer.path];
                if (CGRectContainsPoint(outlinePath.bounds, point)) {
                    return plateDisplay.plate;
                }
            }
            return nil;
        }]
        ignore:nil];

    [tappedPlates subscribe:self.platesToEdit];

    RACSignal *scanForPlates = [[[self.output
        aut_captureImage]
        flattenMap:^(UIImage *image) {
            return [self.plateScanner scanPlatesFromImage:image];
        }]
        initially:^{
            NSLog(@"scanning for plates");
        }];

    RACSignal *timer = [RACSignal interval:1.0 onScheduler:[RACScheduler scheduler]];

    RACSignal *scanAndDrawPlatesAtInterval = [[[[[timer
        mapReplace:scanForPlates]
        switchToLatest]
        deliverOnMainThread]
        map:^(PlateScanResults *plates) {
            return [self drawPlates:plates];
        }]
        switchToLatest];

    RACSignal *active = [[[RACSignal combineLatest:@[ self.aut_isActive, UIApplication.sharedApplication.aut_isActive ]] and]
        doNext:^(id x) {
            NSLog(@"active %@", x);
        }];

    [[RACSignal if:active then:scanAndDrawPlatesAtInterval else:[RACSignal empty]]
        subscribeCompleted:^{}];

    [[[self.platesToEdit
        deliverOnMainThread]
        flattenMap:^(Plate *plate) {
            EditPlateViewController *viewController = [[EditPlateViewController alloc] initWithPlate:plate];

            return [[RACSignal
                concat:@[
                    [self.navigationController aut_pushViewController:viewController animated:YES],
                    viewController.didSubmit,
                    [self.navigationController aut_popToRootViewControllerAnimated:YES],
                ]]
                takeUntil:[self.navigationController aut_didShowViewController:self]];
        }]
        subscribeCompleted:^{}];
}

- (RACSignal *)drawPlates:(PlateScanResults *)plateScanResults {
    return [RACSignal createSignal:^(id<RACSubscriber> subscriber) {

        CGVector scale = (CGVector){
            .dx = self.previewLayer.bounds.size.width / plateScanResults.imageRect.size.width,
            .dy = self.previewLayer.bounds.size.height / plateScanResults.imageRect.size.height,
        };

        NSMutableArray<PlateDisplay *> *displayedPlates = [NSMutableArray array];

        for (Plate *plate in plateScanResults.plates) {
            UIBezierPath *scaledPath = plate.path;
            [scaledPath applyTransform:CGAffineTransformMakeScale(scale.dx, scale.dy)];

            CAShapeLayer *outlineLayer = [CAShapeLayer layer];
            outlineLayer.path = scaledPath.CGPath;
            outlineLayer.strokeColor = [UIColor colorWithRed:0.27f green:0.84f blue:1.00f alpha:1.0f].CGColor;
            outlineLayer.lineWidth = 3.0;
            outlineLayer.lineJoin = kCALineJoinRound;
            outlineLayer.fillColor = UIColor.clearColor.CGColor;

            NSDictionary* attributes = @{
            NSFontAttributeName : [UIFont boldSystemFontOfSize:16.0],
                (NSString*)kCTForegroundColorAttributeName: (id)[UIColor colorWithRed:0.27f green:0.84f blue:1.00f alpha:1.0f].CGColor,
            };
            CATextLayer *numberLayer = [CATextLayer layer];
            numberLayer.contentsScale = UIScreen.mainScreen.scale;
            NSAttributedString *string = [[NSAttributedString alloc] initWithString:plate.number attributes:attributes];
            numberLayer.string = string;
            numberLayer.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5].CGColor;

            CGPoint point = (CGPoint){ CGRectGetMinX(scaledPath.bounds), CGRectGetMaxY(scaledPath.bounds) + 5.0 };
            numberLayer.frame = (CGRect){ .origin = point, .size = string.size };

            PlateDisplay *plateDisplay = [[PlateDisplay alloc] initWithPlate:plate numberLayer:numberLayer outlineLayer:outlineLayer];
            [self.view.layer insertSublayer:plateDisplay.numberLayer above:self.previewLayer];
            [self.view.layer insertSublayer:plateDisplay.outlineLayer above:self.previewLayer];
            [displayedPlates addObject:plateDisplay];
        }

        self.displayedPlates = [displayedPlates copy];

        return [RACDisposable disposableWithBlock:^{
            [subscriber sendCompleted];
            for (PlateDisplay *plateDisplay in displayedPlates) {
                [plateDisplay.numberLayer removeFromSuperlayer];
                [plateDisplay.outlineLayer removeFromSuperlayer];
            }
        }];
    }];
}

@end

@implementation PlateDisplay

- (instancetype)initWithPlate:(Plate *)plate numberLayer:(CATextLayer *)numberLayer outlineLayer:(CAShapeLayer *)outlineLayer {

    self = [super init];

    _plate = plate;
    _numberLayer = numberLayer;
    _outlineLayer = outlineLayer;

    return self;
}

@end
