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
#import "PasscodeCircularView.h" 

static NSString * const EnterPasscodeText = @"Enter Passcode";
static NSString * const ReEnterPasscodeText = @"Re-enter your new Passcode";
static NSString * const EnterCurrentPasscodeText = @"Enter your old Passcode";
static NSString * const IncorrectPasscodeText = @"Incorrect Passcode";
static NSString * const PasscodesDidNotMatchText = @"Passcodes did not Match";

static CGFloat const PasscodeButtonSize = 75;
static CGFloat const PasscodeButtonPaddingHorizontal = 20;
static CGFloat const PasscodeButtonPaddingVertical = 10;

static CGFloat const PasscodeEntryViewSize = 15;
static NSInteger const PasscodeDigitCount = 4;

typedef enum PasscodeWorkflowStep : NSUInteger {
    WorkflowStepOne,
    WorkflowStepSetupPasscodeEnteredOnce,
    WorkflowStepSetupPasscodeEnteredTwice,
    WorkflowStepSetupPasscodesDidNotMatch,
    WorkflowStepChangePasscodeVerified,
    WorkflowStepChangePasscodeNotVerified,
} PasscodeWorkflowStep;

@interface PasscodeViewController ()

@property (strong, nonatomic) UILabel *lblInstruction;
@property (strong, nonatomic) UIButton *btnCancelOrDelete;
@property (strong, nonatomic) UILabel *lblError;
@property (strong, nonatomic) NSString *passcodeFirstEntry;
@property (strong, nonatomic) NSString *passcodeEntered;
@property (strong, nonatomic) NSMutableArray *passcodeEntryViews;
@property (strong, nonatomic) NSMutableArray *passcodeButtons;
@property (assign) NSInteger numberOfDigitsEntered;

@property (assign) PasscodeType passcodeType;
@property (assign) PasscodeWorkflowStep currentWorkflowStep;

@end


@implementation PasscodeViewController

#pragma mark - 
#pragma mark - Lifecycle Methods

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self generateView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

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

#pragma mark -
#pragma mark - Event Handlers

-(void)cancelOrDeleteBtnPressed:(id)sender
{
    if(self.btnCancelOrDelete.tag == 1){
        [_delegate passcodeSetupCancelled];
    }
    else if(self.btnCancelOrDelete.tag == 2)
    {
        NSInteger currentPasscodeLength = self.passcodeEntered.length;
        PasscodeCircularView *pcv = self.passcodeEntryViews[currentPasscodeLength-1];
        [pcv clear];
        self.numberOfDigitsEntered--;
        self.passcodeEntered = [self.passcodeEntered substringToIndex:currentPasscodeLength-1];
        if(self.numberOfDigitsEntered == 0){
            self.btnCancelOrDelete.hidden = YES;
            [self enableCancelIfAllowed];
            self.lblError.hidden = YES;
        }
    }
}

-(void) passcodeBtnPressed:(PasscodeCircularButton *)button
{
    if(self.numberOfDigitsEntered < PasscodeDigitCount)
    {
        NSInteger tag = button.tag;
        NSString *tagStr = [[NSNumber numberWithInteger:tag] stringValue];
        self.passcodeEntered = [NSString stringWithFormat:@"%@%@", self.passcodeEntered, tagStr];
        PasscodeCircularView *pcv = self.passcodeEntryViews[self.numberOfDigitsEntered];
        [pcv fill];
        self.numberOfDigitsEntered++;
        [self enableDelete];
        if(self.numberOfDigitsEntered == PasscodeDigitCount)
        {
            [self evaluatePasscodeEntry];
        }
    }
    
}


#pragma mark -
#pragma mark - Layout Methods

- (NSUInteger)supportedInterfaceOrientations
{
    UIUserInterfaceIdiom interfaceIdiom = [[UIDevice currentDevice] userInterfaceIdiom];
    if (interfaceIdiom == UIUserInterfaceIdiomPad) return UIInterfaceOrientationMaskAll;
    if (interfaceIdiom == UIUserInterfaceIdiomPhone) return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    
    return UIInterfaceOrientationMaskAll;
}
-(void)viewWillLayoutSubviews
{
    [self buildLayout];
}

- (void)generateView
{
    [self createButtons];
    [self createPasscodeEntryView];
    [self buildLayout];
    [self.view setBackgroundColor:[PasscodeManager sharedManager].backgroundColor];
    [self updateLayoutBasedOnWorkflowStep];
}
-(void)createButtons
{
    
    _passcodeButtons = [NSMutableArray new];
    CGRect frame = CGRectMake(0, 0, PasscodeButtonSize, PasscodeButtonSize);

    UIColor *lineColor = [PasscodeManager sharedManager].buttonLineColor;
    UIColor *titleColor = [PasscodeManager sharedManager].buttonTitleColor;
    UIColor *fillColor = [PasscodeManager sharedManager].buttonFillColor;
    UIColor *selectedLineColor = [PasscodeManager sharedManager].buttonHighlightedLineColor;
    UIColor *selectedTitleColor = [PasscodeManager sharedManager].buttonHighlightedTitleColor;
    UIColor *selectedFillColor = [PasscodeManager sharedManager].buttonHighlightedFillColor;
    UIFont *titleFont = [PasscodeManager sharedManager].buttonTitleFont;

    for(int i = 0; i < 10; i++)
    {
        NSString *passcodeNumberStr = [NSString stringWithFormat:@"%d",i];
        PasscodeCircularButton *passcodeButton = [[PasscodeCircularButton alloc]initWithNumber:NSLocalizedString(passcodeNumberStr,nil)
                                                                                         frame:frame
                                                                                     lineColor:lineColor
                                                                                    titleColor:titleColor
                                                                                     fillColor:fillColor
                                                                             selectedLineColor:selectedLineColor
                                                                            selectedTitleColor:selectedTitleColor
                                                                             selectedFillColor:selectedFillColor
                                                                                          font:titleFont];
        
        [passcodeButton addTarget:self action:@selector(passcodeBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_passcodeButtons addObject:passcodeButton];

    }
    
    
    _btnCancelOrDelete = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _btnCancelOrDelete.frame = frame;
    [_btnCancelOrDelete setTitleColor:[PasscodeManager sharedManager].cancelOrDeleteButtonColor forState:UIControlStateNormal];
    _btnCancelOrDelete.hidden = YES;
    [_btnCancelOrDelete setTitle:@"" forState:UIControlStateNormal];
    [_btnCancelOrDelete addTarget:self action:@selector(cancelOrDeleteBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    _btnCancelOrDelete.titleLabel.font = [PasscodeManager sharedManager].cancelOrDeleteButtonFont;
    
    _lblInstruction = [[UILabel alloc]initWithFrame:CGRectZero];
    _lblInstruction.textColor = [PasscodeManager sharedManager].instructionsLabelColor;
    _lblInstruction.font = [PasscodeManager sharedManager].instructionsLabelFont;
    
    _lblError = [[UILabel alloc]initWithFrame:CGRectZero];
    _lblError.textColor = [PasscodeManager sharedManager].errorLabelColor;
    _lblError.backgroundColor = [PasscodeManager sharedManager].errorLabelBackgroundColor;
    _lblError.font = [PasscodeManager sharedManager].errorLabelFont;
}

- (void)buildLayout
{
    CGFloat buttonRowWidth = (PasscodeButtonSize * 3) + (PasscodeButtonPaddingHorizontal * 2);
  
    CGFloat firstButtonX = ([self returnWidth]/2) - (buttonRowWidth/2) + 0.5;
    CGFloat middleButtonX = firstButtonX + PasscodeButtonSize + PasscodeButtonPaddingHorizontal;
    CGFloat lastButtonX = middleButtonX + PasscodeButtonSize + PasscodeButtonPaddingHorizontal;
    
    CGFloat firstRowY = ([self returnHeight]/2) - PasscodeButtonSize - PasscodeButtonPaddingVertical * 3;
    CGFloat middleRowY = firstRowY + PasscodeButtonSize + PasscodeButtonPaddingVertical;
    CGFloat lastRowY = middleRowY + PasscodeButtonSize + PasscodeButtonPaddingVertical;
    CGFloat zeroRowY = lastRowY + PasscodeButtonSize + PasscodeButtonPaddingVertical;

    NSValue *frameBtnOne = [NSValue valueWithCGRect:CGRectMake(firstButtonX, firstRowY, PasscodeButtonSize, PasscodeButtonSize)];
    NSValue *frameBtnTwo = [NSValue valueWithCGRect:CGRectMake(middleButtonX, firstRowY, PasscodeButtonSize, PasscodeButtonSize)];
    NSValue *frameBtnThree = [NSValue valueWithCGRect:CGRectMake(lastButtonX, firstRowY, PasscodeButtonSize, PasscodeButtonSize)];
    NSValue *frameBtnFour = [NSValue valueWithCGRect:CGRectMake(firstButtonX, middleRowY, PasscodeButtonSize, PasscodeButtonSize)];
    NSValue *frameBtnFive = [NSValue valueWithCGRect:CGRectMake(middleButtonX, middleRowY, PasscodeButtonSize, PasscodeButtonSize)];
    NSValue *frameBtnSix = [NSValue valueWithCGRect:CGRectMake(lastButtonX, middleRowY, PasscodeButtonSize, PasscodeButtonSize)];
    NSValue *frameBtnSeven = [NSValue valueWithCGRect:CGRectMake(firstButtonX, lastRowY, PasscodeButtonSize, PasscodeButtonSize)];
    NSValue *frameBtnEight = [NSValue valueWithCGRect:CGRectMake(middleButtonX, lastRowY, PasscodeButtonSize, PasscodeButtonSize)];
    NSValue *frameBtnNine = [NSValue valueWithCGRect:CGRectMake(lastButtonX, lastRowY, PasscodeButtonSize, PasscodeButtonSize)];
    NSValue *frameBtnZero = [NSValue valueWithCGRect:CGRectMake(middleButtonX, zeroRowY, PasscodeButtonSize, PasscodeButtonSize)];
   
    CGRect frameBtnCancel = CGRectMake(lastButtonX, zeroRowY, PasscodeButtonSize, PasscodeButtonSize);
    CGRect frameLblInstruction = CGRectMake(0, 0, 250, 20);
    CGRect frameLblError = CGRectMake(0, 0, 200, 20);
    
    NSArray *buttonFrames = @[frameBtnZero, frameBtnOne, frameBtnTwo, frameBtnThree, frameBtnFour, frameBtnFive, frameBtnSix, frameBtnSeven, frameBtnEight, frameBtnNine];
                                                                                                                    
    for(int i = 0; i < 10; i++)
    {
        PasscodeCircularButton *passcodeButton = _passcodeButtons[i];
        passcodeButton.frame = [buttonFrames[i] CGRectValue];
        [self.view addSubview:passcodeButton];
    }

    _btnCancelOrDelete.frame = frameBtnCancel;

    _lblInstruction.textAlignment = NSTextAlignmentCenter;
    _lblInstruction.frame = frameLblInstruction;
    _lblInstruction.center = CGPointMake([self returnWidth]/2, firstRowY - (PasscodeButtonPaddingVertical * 10));

    _lblError.textAlignment = NSTextAlignmentCenter;
    _lblError.frame = frameLblError;
    _lblError.center = CGPointMake([self returnWidth]/2, firstRowY - (PasscodeButtonPaddingVertical * 3));
    _lblError.layer.cornerRadius = 10;
    _lblError.hidden = YES;

    [self.view addSubview:_btnCancelOrDelete];

    [self.view addSubview:_lblInstruction];
    [self.view addSubview:_lblError];

    
    CGFloat passcodeEntryViewsY = firstRowY - PasscodeButtonPaddingVertical * 7;
    CGFloat passcodeEntryViewWidth = (PasscodeDigitCount * PasscodeEntryViewSize) + ((PasscodeDigitCount - 1) * PasscodeButtonPaddingHorizontal);
    CGFloat xPoint = ([self returnWidth] - passcodeEntryViewWidth) / 2;
    
    for (PasscodeCircularView *circularView in self.passcodeEntryViews){
        CGRect frame = CGRectMake(xPoint, passcodeEntryViewsY, PasscodeEntryViewSize, PasscodeEntryViewSize);
        circularView.frame = frame;
        xPoint = xPoint + PasscodeEntryViewSize + PasscodeButtonPaddingHorizontal;
        [self.view addSubview:circularView];
    }
}

- (void)updateLayoutBasedOnWorkflowStep
{
    self.btnCancelOrDelete.hidden = YES;
    
    if(self.passcodeType == PasscodeTypeSetup)
    {
        if(self.currentWorkflowStep == WorkflowStepOne)
        {
            self.lblInstruction.text = NSLocalizedString(EnterPasscodeText, nil);
        }
        else if(self.currentWorkflowStep == WorkflowStepSetupPasscodeEnteredOnce)
        {
            self.lblInstruction.text = NSLocalizedString(ReEnterPasscodeText, nil);
        }
        else if(self.currentWorkflowStep == WorkflowStepSetupPasscodesDidNotMatch)
        {
            self.lblInstruction.text = NSLocalizedString(EnterPasscodeText, nil);
            self.currentWorkflowStep = WorkflowStepOne;
        }
    }
    else if(self.passcodeType == PasscodeTypeVerify || self.passcodeType == PasscodeTypeVerifyForSettingChange){
        self.lblInstruction.text = NSLocalizedString(EnterPasscodeText, nil);;
        if(self.passcodeType == PasscodeTypeVerifyForSettingChange){
        }
    }
    else if(self.passcodeType == PasscodeTypeChangePasscode)
    {
        if(self.currentWorkflowStep == WorkflowStepOne){
            self.lblInstruction.text = NSLocalizedString(EnterCurrentPasscodeText, nil);
        }
    }
    [self enableCancelIfAllowed];
    [self resetPasscodeEntryView];
}

#pragma mark - 
#pragma mark - UIView Handlers

-(void)enableDelete
{
    if(!self.btnCancelOrDelete.tag != 2){
        self.btnCancelOrDelete.tag = 2;
        [self.btnCancelOrDelete setTitle:NSLocalizedString(@"Delete",nil) forState:UIControlStateNormal];
    }
    if(self.btnCancelOrDelete.hidden){
        self.btnCancelOrDelete.hidden = NO;
    }
}

-(void)showErrorMessage:(NSString *)errorMessage
{
    self.lblError.hidden = NO;
    self.lblError.text = errorMessage;
}
- (void)enableCancelIfAllowed
{
    if(self.passcodeType == PasscodeTypeChangePasscode || self.passcodeType == PasscodeTypeSetup || self.passcodeType == PasscodeTypeVerifyForSettingChange){
        [_btnCancelOrDelete setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        _btnCancelOrDelete.tag = 1;
        _btnCancelOrDelete.hidden = NO;
    }
}
- (void) createPasscodeEntryView
{
    self.passcodeEntryViews = [NSMutableArray new];
    self.passcodeEntered = @"";
    self.numberOfDigitsEntered = 0;
    UIColor *lineColor = [PasscodeManager sharedManager].passcodeViewLineColor;
    UIColor *fillColor = [PasscodeManager sharedManager].passcodeViewFillColor;
    CGRect frame = CGRectMake(0, 0, PasscodeEntryViewSize, PasscodeEntryViewSize);
    
    for (int i=0; i < PasscodeDigitCount; i++){
        PasscodeCircularView *pcv = [[PasscodeCircularView alloc]initWithFrame:frame
                                                                     lineColor:lineColor
                                                                     fillColor:fillColor];
        [self.passcodeEntryViews addObject:pcv];
    }
}

- (void) resetPasscodeEntryView
{
    for(PasscodeCircularView *pcv in self.passcodeEntryViews)
    {
        [pcv clear];
    }
    self.passcodeEntered = @"";
    self.numberOfDigitsEntered = 0;
}

#pragma mark - 
#pragma mark - Helper methods

- (CGFloat)returnWidth
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(orientation)){
        return self.view.frame.size.height;
    }
    else{
        return self.view.frame.size.width;
    }
}

- (CGFloat)returnHeight
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(orientation)){
        return self.view.frame.size.width;
    }
    else{
        return self.view.frame.size.height;
    }
}

-(void)evaluatePasscodeEntry{
    
    self.lblError.hidden = YES;
    
    if(self.passcodeType == PasscodeTypeSetup){
        if(self.currentWorkflowStep == WorkflowStepOne){
            self.currentWorkflowStep = WorkflowStepSetupPasscodeEnteredOnce;
            self.passcodeFirstEntry = self.passcodeEntered;
            [self updateLayoutBasedOnWorkflowStep];
        }
        else if(self.currentWorkflowStep == WorkflowStepSetupPasscodeEnteredOnce)
        {
            if([self.passcodeFirstEntry isEqualToString:self.passcodeEntered])
            {
                [[PasscodeManager sharedManager] setPasscode:self.passcodeEntered];
                [_delegate didSetupPasscode];
            }
            else
            {
                self.currentWorkflowStep = WorkflowStepSetupPasscodesDidNotMatch;
                [self showErrorMessage:NSLocalizedString(PasscodesDidNotMatchText, nil)];
                [self updateLayoutBasedOnWorkflowStep];
            }
        }
    }
    else if(self.passcodeType == PasscodeTypeVerify || self.passcodeType == PasscodeTypeVerifyForSettingChange){
        if([[PasscodeManager sharedManager] isPasscodeCorrect:self.passcodeEntered]){
            [_delegate didVerifyPasscode];
        }
        else{
            [self showErrorMessage:NSLocalizedString(IncorrectPasscodeText, nil)];

            self.currentWorkflowStep = WorkflowStepOne;
            [self updateLayoutBasedOnWorkflowStep];
        }
    }
    else if(self.passcodeType == PasscodeTypeChangePasscode)
    {
        if([[PasscodeManager sharedManager] isPasscodeCorrect:self.passcodeEntered]){
            self.passcodeType = PasscodeTypeSetup;
            self.currentWorkflowStep = WorkflowStepOne;
            [self updateLayoutBasedOnWorkflowStep];
        }
        else{
            [self showErrorMessage:NSLocalizedString(IncorrectPasscodeText, nil)];
            self.currentWorkflowStep = WorkflowStepOne;
            [self updateLayoutBasedOnWorkflowStep];
        }
        
    }

}


-(void)setDelegate:(id)newDelegate{
    _delegate = newDelegate;
}

@end
