//
//  MainViewController.m
//  WPiOSPasscodeLock
//
//  Created by Basar Akyelli on 2/14/14.
//  Copyright (c) 2014 Basar Akyelli. All rights reserved.
//

#import "PasscodeViewController.h"
#import "PasscodeManager.h" 
#import "PasscodeCircularButton.h"


static NSString * const kEnterPasscodeLabel = @"Enter your passcode.";
static NSString * const kReEnterPasscodeLabel = @"Re-enter your passcode.";
static NSString * const kEnterCurrentPasscodeLabel = @"Enter your current passcode.";

@interface PasscodeViewController ()

@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) PasscodeCircularButton *cancelButton;
@property (strong, nonatomic) NSString *passcodeFirstEntry;
@property (assign) PasscodeType passcodeType;
@property (assign) PasscodeWorkflowStep currentWorkflowStep;

@end


@implementation PasscodeViewController

-(id) initWithPasscodeType:(PasscodeType)type withDelegate:(id<PasscodeViewControllerDelegate>)delegate
{
    self = [super init];
    
    if(self)
    {
        self.currentWorkflowStep = WorkflowStepOne;
        self.passcodeType = type;
        self.delegate = delegate; 
    }
    return self;
}

- (void)enableCancel
{
    _cancelButton = [PasscodeCircularButton buttonWithType:UIButtonTypeRoundedRect];
    _cancelButton.lineColor = [UIColor blackColor];
    _cancelButton.frame = CGRectMake(110, 160, 50, 50);
    [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(cancelBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cancelButton];
    [self.cancelButton drawCircular];
}

- (void)createLayout
{

    [self.view setBackgroundColor:[UIColor whiteColor]];
    _label = [[UILabel alloc]initWithFrame:CGRectMake(50,50,200,20)];
    [self.view addSubview:_label];
    
    [self updateLayoutBasedOnWorkflowStep];
    
    _textField = [[UITextField alloc]initWithFrame:CGRectMake(50, 100, 200, 50)];
    [_textField setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:_textField];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(50, 160, 50, 50);
    [button setTitle:@"OK" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createLayout];
}

-(void)btnPressed:(UIButton *)button
{
    if(self.passcodeType == PasscodeTypeSetup){
        if(self.currentWorkflowStep == WorkflowStepOne){
            self.currentWorkflowStep = WorkflowStepSetupPasscodeEnteredOnce;
            self.passcodeFirstEntry = self.textField.text;
            [self updateLayoutBasedOnWorkflowStep];
        }
        else if(self.currentWorkflowStep == WorkflowStepSetupPasscodeEnteredOnce)
        {
            if([self.passcodeFirstEntry isEqualToString:self.textField.text])
            {
                [[PasscodeManager sharedManager] setPasscode:self.textField.text];
                [_delegate didSetupPasscode];
            }
            else
            {
                self.currentWorkflowStep = WorkflowStepSetupPasscodesDidNotMatch;
                [self updateLayoutBasedOnWorkflowStep];
            }
        }
    }
    else if(self.passcodeType == PasscodeTypeVerify || self.passcodeType == PasscodeTypeVerifyForSettingChange){
        if([[PasscodeManager sharedManager] isPasscodeCorrect:self.textField.text]){
            [_delegate didVerifyPasscode];
        }
        else{
            self.currentWorkflowStep = WorkflowStepOne;
            [self updateLayoutBasedOnWorkflowStep];
        }
    }
    else if(self.passcodeType == PasscodeTypeChangePasscode)
    {
        if([[PasscodeManager sharedManager] isPasscodeCorrect:self.textField.text]){
            self.passcodeType = PasscodeTypeSetup;
            self.currentWorkflowStep = WorkflowStepOne;
            [self updateLayoutBasedOnWorkflowStep];
        }
        else{
            self.currentWorkflowStep = WorkflowStepOne;
            [self updateLayoutBasedOnWorkflowStep];
        }
        
    }
}
- (void)updateLayoutBasedOnWorkflowStep
{
    if(self.passcodeType == PasscodeTypeSetup)
    {
        if(self.currentWorkflowStep == WorkflowStepOne)
        {
            self.label.text = NSLocalizedString(kEnterPasscodeLabel, nil);
            self.textField.text = @"";
        }
        else if(self.currentWorkflowStep == WorkflowStepSetupPasscodeEnteredOnce)
        {
            self.label.text = NSLocalizedString(kReEnterPasscodeLabel, nil);
            self.textField.text = @"";
        }
        else if(self.currentWorkflowStep == WorkflowStepSetupPasscodesDidNotMatch)
        {
            self.label.text = NSLocalizedString(kEnterPasscodeLabel, nil);
            self.currentWorkflowStep = WorkflowStepOne;
            self.textField.text = @"";
        }
    }
    else if(self.passcodeType == PasscodeTypeVerify || self.passcodeType == PasscodeTypeVerifyForSettingChange){
        self.label.text = NSLocalizedString(kEnterPasscodeLabel, nil);;
        self.textField.text = @"";
        if(self.passcodeType == PasscodeTypeVerifyForSettingChange){
            [self enableCancel];
        }
    }
    else if(self.passcodeType == PasscodeTypeChangePasscode)
    {
        if(self.currentWorkflowStep == WorkflowStepOne){
            self.label.text = NSLocalizedString(kEnterCurrentPasscodeLabel, nil);
            self.textField.text = @"";
            [self enableCancel];
        }
    }
}
-(void)cancelBtnPressed:(id)sender
{
    [_delegate passcodeSetupCancelled];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)setDelegate:(id)newDelegate{
    _delegate = newDelegate;
}







//-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//{
//    [self rotateAccordingToStatusBarOrientationAndSupportedOrientations];
//}

//#pragma mark - TODO
//- (void)rotateAccordingToStatusBarOrientationAndSupportedOrientations {
//	UIInterfaceOrientation orientation = [self desiredOrientation];
//    CGFloat angle = UIInterfaceOrientationAngleOfOrientation(orientation);
//    CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
//	
//    [self setIfNotEqualTransform: transform
//						   frame: self.view.window.bounds];
//}
//
//
//- (void)setIfNotEqualTransform:(CGAffineTransform)transform frame:(CGRect)frame {
//    if(!CGAffineTransformEqualToTransform(self.view.transform, transform)) {
//        self.view.transform = transform;
//    }
//    if(!CGRectEqualToRect(self.view.frame, frame)) {
//        self.view.frame = frame;
//    }
//}
//CGFloat UIInterfaceOrientationAngleOfOrientation(UIInterfaceOrientation orientation) {
//    CGFloat angle;
//	
//    switch (orientation) {
//        case UIInterfaceOrientationPortraitUpsideDown:
//            angle = M_PI;
//            break;
//        case UIInterfaceOrientationLandscapeLeft:
//            angle = -M_PI_2;
//            break;
//        case UIInterfaceOrientationLandscapeRight:
//            angle = M_PI_2;
//            break;
//        default:
//            angle = 0.0;
//            break;
//    }
//	
//    return angle;
//}
//
//- (UIInterfaceOrientation)desiredOrientation {
//    UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
//    UIInterfaceOrientationMask statusBarOrientationAsMask = UIInterfaceOrientationMaskFromOrientation(statusBarOrientation);
//    if(self.supportedInterfaceOrientations & statusBarOrientationAsMask) {
//        return statusBarOrientation;
//    }
//    else {
//        if(self.supportedInterfaceOrientations & UIInterfaceOrientationMaskPortrait) {
//            return UIInterfaceOrientationPortrait;
//        }
//        else if(self.supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeLeft) {
//            return UIInterfaceOrientationLandscapeLeft;
//        }
//        else if(self.supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeRight) {
//            return UIInterfaceOrientationLandscapeRight;
//        }
//        else {
//            return UIInterfaceOrientationPortraitUpsideDown;
//        }
//    }
//}
//UIInterfaceOrientationMask UIInterfaceOrientationMaskFromOrientation(UIInterfaceOrientation orientation) {
//    return 1 << orientation;
//}

@end
