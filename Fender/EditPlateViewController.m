//
//  EditPlateViewController.m
//  Fender
//
//  Created by Eric Horacek on 11/13/15.
//  Copyright © 2015 Automatic Labs. All rights reserved.
//

@import ReactiveCocoa;
@import AFNetworking;

#import "AFHTTPSessionManager+UploadMessage.h"

#import "Plate.h"

#import "EditPlateViewController.h"

@interface EditPlateViewController () <UITextFieldDelegate>

@property (readonly, nonatomic, strong) NSCharacterSet *validCharacterSet;
@property (readwrite, nonatomic, strong) UILabel *stateLabel;
@property (readwrite, nonatomic, strong) UITextField *numberEntryField;
@property (readonly, nonatomic, strong) RACSignal *validPlate;
@property (readwrite, nonatomic, strong) UIView *plateView;
@property (readonly, nonatomic, strong) AFHTTPSessionManager *manager;
@property (readonly, nonatomic, strong) RACCommand *submitCommand;

@end

@implementation EditPlateViewController

- (instancetype)initWithPlate:(Plate *)plate {
    self = [super initWithNibName:nil bundle:nil];

    _plate = plate;

    NSString *validCharacterSetString = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789";
    _validCharacterSet = [NSCharacterSet characterSetWithCharactersInString:validCharacterSetString];

    self.navigationItem.title = @"Fender";
    _validPlate = [RACObserve(plate, number) map:^id(id value) {
        return @([value length] > 0);
    }];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:plate.input];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.layer.masksToBounds = YES;
    imageView.frame = (CGRect){ .size.width = 80.0, .size.height = 40.0 };
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:imageView];

    _manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://fender-api.automatic.co"]];
    _manager.requestSerializer = [[AFJSONRequestSerializer alloc] init];

    _submitCommand = [[RACCommand alloc] initWithSignalBlock:^(NSString *text) {
        return [[[self.manager uploadMessage:text forPlate:self.plate]
            doError:^(NSError *error) {
                NSLog(@"error uploading message %@", error);
            }]
            doCompleted:^{
                NSLog(@"uploaded message");
            }];
    }];

    _didSubmit = [[[[[_submitCommand.executionSignals
        concat]
        take:1]
        ignoreValues]
        deliverOnMainThread]
        doCompleted:^() {
            NSLog(@"submitted");
        }];

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1.0];

    self.plateView = [[UIView alloc] init];
    self.plateView.backgroundColor = [UIColor whiteColor];
    self.plateView.layer.cornerRadius = 5.0;
    self.plateView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.plateView.heightAnchor constraintEqualToAnchor:self.plateView.widthAnchor multiplier:0.5].active = YES;

    self.numberEntryField = [[UITextField alloc] init];
    self.numberEntryField.delegate = self;
    self.numberEntryField.placeholder = @"123ABC";
    self.numberEntryField.adjustsFontSizeToFitWidth = YES;
    self.numberEntryField.translatesAutoresizingMaskIntoConstraints = NO;
    self.numberEntryField.textAlignment = NSTextAlignmentCenter;
    self.numberEntryField.font = [UIFont fontWithName:@"Menlo-Bold" size:70];
    RAC(self.numberEntryField, text) = RACObserve(self.plate, number);
    RAC(self.plate, number) = [[self.numberEntryField rac_newTextChannel] skip:1];
    [self.plateView addSubview:self.numberEntryField];

    [self.numberEntryField.leftAnchor constraintEqualToAnchor:self.plateView.leftAnchor constant:10.0].active = YES;
    [self.numberEntryField.rightAnchor constraintEqualToAnchor:self.plateView.rightAnchor constant:-10.0].active = YES;
    [self.numberEntryField.centerYAnchor constraintEqualToAnchor:self.plateView.centerYAnchor].active = YES;

    UIStackView *firstStackView = [self createButtonRowWithText:@[@"😄", @"👍", @"👋"] command:self.submitCommand];
    UIStackView *secondStackView = [self createButtonRowWithText:@[@"😘", @"🖕", @"😡"] command:self.submitCommand];
    UIStackView *thirdStackView = [self createButtonRowWithText:@[@"🏎", @"☠", @"🚨"] command:self.submitCommand];

    UIStackView *contentStackView = [[UIStackView alloc] init];
    contentStackView.translatesAutoresizingMaskIntoConstraints = NO;
    contentStackView.layoutMarginsRelativeArrangement = YES;
    contentStackView.layoutMargins = UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0);
    contentStackView.alignment = UIStackViewAlignmentFill;
    contentStackView.distribution = UIStackViewDistributionEqualSpacing;
    contentStackView.axis = UILayoutConstraintAxisVertical;
    [contentStackView addArrangedSubview:self.plateView];
    [contentStackView addArrangedSubview:firstStackView];
    [contentStackView addArrangedSubview:secondStackView];
    [contentStackView addArrangedSubview:thirdStackView];
    [self.view addSubview:contentStackView];

    [contentStackView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [contentStackView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [contentStackView.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor].active = YES;
    [contentStackView.bottomAnchor constraintEqualToAnchor:self.bottomLayoutGuide.topAnchor].active = YES;
}

- (BOOL)isTextValid:(NSString *)text {
    if (text.length > 10) return NO;

    // Ensure the characters are from the valid set of characters
    return ([text rangeOfCharacterFromSet:self.validCharacterSet.invertedSet].location == NSNotFound);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Calculate the string that results from performing this operation
    NSString *resultingString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (![self isTextValid:resultingString]) return NO;

    // not so easy to get an UITextRange from an NSRange...
    // thanks to Nicolas Bachschmidt (see http://stackoverflow.com/questions/9126709/create-uitextrange-from-nsrange)
    UITextPosition *beginning = textField.beginningOfDocument;
    UITextPosition *start = [textField positionFromPosition:beginning offset:range.location];
    UITextPosition *end = [textField positionFromPosition:start offset:range.length];
    UITextRange *textRange = [textField textRangeFromPosition:start toPosition:end];

    // replace the text in the range with the upper case version of the replacement string
    [textField replaceRange:textRange withText:[string uppercaseString]];

    // don't change the characters automatically
    return NO;
}

- (UIStackView *)createButtonRowWithText:(NSArray<NSString *> *)buttonText command:(RACCommand *)command {
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.distribution = UIStackViewDistributionEqualSpacing;

    for (NSString *text in buttonText) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.backgroundColor = [UIColor whiteColor];
        button.contentEdgeInsets = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
        button.translatesAutoresizingMaskIntoConstraints = NO;
        button.titleLabel.font = [UIFont systemFontOfSize:50.0];
        [button setTitle:text forState:UIControlStateNormal];

        button.rac_command = [[RACCommand alloc] initWithEnabled:self.validPlate signalBlock:^(id _) {
            return [command execute:text];
        }];

        [button.widthAnchor constraintEqualToAnchor:button.heightAnchor].active = YES;

        RAC(button.layer, cornerRadius) = [RACObserve(button, bounds) map:^id(NSValue *value) {
            return @(value.CGRectValue.size.height / 2.0);
        }];

        RAC(button, alpha) = [self.validPlate map:^id(NSNumber *value) {
            return value.boolValue ? @1.0 : @0.5;
        }];

        [stackView addArrangedSubview:button];
    }

    return stackView;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


@end
