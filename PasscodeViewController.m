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

static NSString * const EnterPasscodeLabel = @"Enter Passcode";
static NSString * const ReEnterPasscodeLabel = @"Re-enter your new Passcode";
static NSString * const EnterCurrentPasscodeLabel = @"Enter your old Passcode";

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

@property (strong, nonatomic) PasscodeCircularButton *btnDelete;
@property (strong, nonatomic) PasscodeCircularButton *btnZero;
@property (strong, nonatomic) PasscodeCircularButton *btnOne;
@property (strong, nonatomic) PasscodeCircularButton *btnTwo;
@property (strong, nonatomic) PasscodeCircularButton *btnThree;
@property (strong, nonatomic) PasscodeCircularButton *btnFour;
@property (strong, nonatomic) PasscodeCircularButton *btnFive;
@property (strong, nonatomic) PasscodeCircularButton *btnSix;
@property (strong, nonatomic) PasscodeCircularButton *btnSeven;
@property (strong, nonatomic) PasscodeCircularButton *btnEight;
@property (strong, nonatomic) PasscodeCircularButton *btnNine;

@property (strong, nonatomic) NSString *passcodeFirstEntry;
@property (strong, nonatomic) NSString *passcodeEntered;
@property (strong, nonatomic) NSMutableArray *passcodeEntryViews;
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
    CGRect frame = CGRectMake(0, 0, PasscodeButtonSize, PasscodeButtonSize);

    UIColor *lineColor = [PasscodeManager sharedManager].buttonLineColor;
    UIColor *titleColor = [PasscodeManager sharedManager].buttonTitleColor;
    UIColor *fillColor = [PasscodeManager sharedManager].buttonFillColor;
    UIColor *selectedLineColor = [PasscodeManager sharedManager].buttonHighlightedLineColor;
    UIColor *selectedTitleColor = [PasscodeManager sharedManager].buttonHighlightedTitleColor;
    UIColor *selectedFillColor = [PasscodeManager sharedManager].buttonHighlightedFillColor;
    UIFont *titleFont = [PasscodeManager sharedManager].buttonTitleFont;
    
    _btnOne = [[PasscodeCircularButton alloc]initWithNumber:NSLocalizedString(@"1",nil)
                                                      frame:frame
                                                  lineColor:lineColor
                                                 titleColor:titleColor
                                                  fillColor:fillColor
                                          selectedLineColor:selectedLineColor
                                         selectedTitleColor:selectedTitleColor
                                          selectedFillColor:selectedFillColor
                                                       font:titleFont];
    
    [_btnOne addTarget:self action:@selector(passcodeBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _btnTwo = [[PasscodeCircularButton alloc]initWithNumber:NSLocalizedString(@"2",nil)
                                                      frame:frame
                                                  lineColor:lineColor
                                                 titleColor:titleColor
                                                  fillColor:fillColor
                                          selectedLineColor:selectedLineColor
                                         selectedTitleColor:selectedTitleColor
                                          selectedFillColor:selectedFillColor
                                                       font:titleFont];

    
    [_btnTwo addTarget:self action:@selector(passcodeBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _btnThree = [[PasscodeCircularButton alloc]initWithNumber:NSLocalizedString(@"3",nil)
                                                        frame:frame
                                                    lineColor:lineColor
                                                   titleColor:titleColor
                                                    fillColor:fillColor
                                            selectedLineColor:selectedLineColor
                                           selectedTitleColor:selectedTitleColor
                                            selectedFillColor:selectedFillColor
                                                         font:titleFont];

    
    [_btnThree addTarget:self action:@selector(passcodeBtnPressed:) forControlEvents:UIControlEventTouchUpInside];

    _btnFour = [[PasscodeCircularButton alloc]initWithNumber:NSLocalizedString(@"4", nil)
                                                       frame:frame
                                                   lineColor:lineColor
                                                  titleColor:titleColor
                                                   fillColor:fillColor
                                           selectedLineColor:selectedLineColor
                                          selectedTitleColor:selectedTitleColor
                                           selectedFillColor:selectedFillColor
                                                        font:titleFont];

    
    [_btnFour addTarget:self action:@selector(passcodeBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _btnFive = [[PasscodeCircularButton alloc]initWithNumber:NSLocalizedString(@"5", nil)
                                                       frame:frame
                                                   lineColor:lineColor
                                                  titleColor:titleColor
                                                   fillColor:fillColor
                                           selectedLineColor:selectedLineColor
                                          selectedTitleColor:selectedTitleColor
                                           selectedFillColor:selectedFillColor
                                                        font:titleFont];

    
    [_btnFive addTarget:self action:@selector(passcodeBtnPressed:) forControlEvents:UIControlEventTouchUpInside];

    _btnSix = [[PasscodeCircularButton alloc]initWithNumber:NSLocalizedString(@"6",nil)
                                                      frame:frame
                                                  lineColor:lineColor
                                                 titleColor:titleColor
                                                  fillColor:fillColor
                                          selectedLineColor:selectedLineColor
                                         selectedTitleColor:selectedTitleColor
                                          selectedFillColor:selectedFillColor
                                                       font:titleFont];

    
    [_btnSix addTarget:self action:@selector(passcodeBtnPressed:) forControlEvents:UIControlEventTouchUpInside];

    _btnSeven = [[PasscodeCircularButton alloc]initWithNumber:NSLocalizedString(@"7",nil)
                                                        frame:frame
                                                    lineColor:lineColor
                                                   titleColor:titleColor
                                                    fillColor:fillColor
                                            selectedLineColor:selectedLineColor
                                           selectedTitleColor:selectedTitleColor
                                            selectedFillColor:selectedFillColor
                                                         font:titleFont];

    
    [_btnSeven addTarget:self action:@selector(passcodeBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _btnEight = [[PasscodeCircularButton alloc]initWithNumber:NSLocalizedString(@"8",nil)
                                                        frame:frame
                                                    lineColor:lineColor
                                                   titleColor:titleColor
                                                    fillColor:fillColor
                                            selectedLineColor:selectedLineColor
                                           selectedTitleColor:selectedTitleColor
                                            selectedFillColor:selectedFillColor
                                                         font:titleFont];

    
    [_btnEight addTarget:self action:@selector(passcodeBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _btnNine = [[PasscodeCircularButton alloc]initWithNumber:NSLocalizedString(@"9",nil)
                                                       frame:frame
                                                   lineColor:lineColor
                                                  titleColor:titleColor
                                                   fillColor:fillColor
                                           selectedLineColor:selectedLineColor
                                          selectedTitleColor:selectedTitleColor
                                           selectedFillColor:selectedFillColor
                                                        font:titleFont];

    
    [_btnNine addTarget:self action:@selector(passcodeBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _btnZero = [[PasscodeCircularButton alloc]initWithNumber:NSLocalizedString(@"0",nil)
                                                       frame:frame
                                                   lineColor:lineColor
                                                  titleColor:titleColor
                                                   fillColor:fillColor
                                           selectedLineColor:selectedLineColor
                                          selectedTitleColor:selectedTitleColor
                                           selectedFillColor:selectedFillColor
                                                        font:titleFont];

    
    [_btnZero addTarget:self action:@selector(passcodeBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
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

    CGRect frameBtnOne = CGRectMake(firstButtonX, firstRowY, PasscodeButtonSize, PasscodeButtonSize);
    CGRect frameBtnTwo = CGRectMake(middleButtonX, firstRowY, PasscodeButtonSize, PasscodeButtonSize);
    CGRect frameBtnThree = CGRectMake(lastButtonX, firstRowY, PasscodeButtonSize, PasscodeButtonSize);
    CGRect frameBtnFour = CGRectMake(firstButtonX, middleRowY, PasscodeButtonSize, PasscodeButtonSize);
    CGRect frameBtnFive = CGRectMake(middleButtonX, middleRowY, PasscodeButtonSize, PasscodeButtonSize);
    CGRect frameBtnSix = CGRectMake(lastButtonX, middleRowY, PasscodeButtonSize, PasscodeButtonSize);
    CGRect frameBtnSeven = CGRectMake(firstButtonX, lastRowY, PasscodeButtonSize, PasscodeButtonSize);
    CGRect frameBtnEight = CGRectMake(middleButtonX, lastRowY, PasscodeButtonSize, PasscodeButtonSize);
    CGRect frameBtnNine = CGRectMake(lastButtonX, lastRowY, PasscodeButtonSize, PasscodeButtonSize);
    CGRect frameBtnZero = CGRectMake(middleButtonX, zeroRowY, PasscodeButtonSize, PasscodeButtonSize);
    CGRect frameBtnCancel = CGRectMake(lastButtonX, zeroRowY, PasscodeButtonSize, PasscodeButtonSize);
    CGRect frameLblInstruction = CGRectMake(0, 0, 250, 20);

    _btnOne.frame = frameBtnOne;
    _btnTwo.frame = frameBtnTwo;
    _btnThree.frame = frameBtnThree;
    _btnFour.frame = frameBtnFour;
    _btnFive.frame = frameBtnFive;
    _btnSix.frame = frameBtnSix;
    _btnSeven.frame = frameBtnSeven;
    _btnEight.frame = frameBtnEight;
    _btnNine.frame = frameBtnNine;
    _btnZero.frame = frameBtnZero;
    _btnCancelOrDelete.frame = frameBtnCancel;

    _lblInstruction.textAlignment = NSTextAlignmentCenter;
    _lblInstruction.frame = frameLblInstruction;
    _lblInstruction.center = CGPointMake([self returnWidth]/2, firstRowY - (PasscodeButtonPaddingVertical * 10));

    [self.view addSubview:_btnOne];
    [self.view addSubview:_btnTwo];
    [self.view addSubview:_btnThree];
    [self.view addSubview:_btnFour];
    [self.view addSubview:_btnFive];
    [self.view addSubview:_btnSix];
    [self.view addSubview:_btnSeven];
    [self.view addSubview:_btnEight];
    [self.view addSubview:_btnNine];
    [self.view addSubview:_btnZero];
    [self.view addSubview:_btnCancelOrDelete];

    [self.view addSubview:_lblInstruction];
    
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
            self.lblInstruction.text = NSLocalizedString(EnterPasscodeLabel, nil);
        }
        else if(self.currentWorkflowStep == WorkflowStepSetupPasscodeEnteredOnce)
        {
            self.lblInstruction.text = NSLocalizedString(ReEnterPasscodeLabel, nil);
        }
        else if(self.currentWorkflowStep == WorkflowStepSetupPasscodesDidNotMatch)
        {
            self.lblInstruction.text = NSLocalizedString(EnterPasscodeLabel, nil);
            self.currentWorkflowStep = WorkflowStepOne;
        }
    }
    else if(self.passcodeType == PasscodeTypeVerify || self.passcodeType == PasscodeTypeVerifyForSettingChange){
        self.lblInstruction.text = NSLocalizedString(EnterPasscodeLabel, nil);;
        if(self.passcodeType == PasscodeTypeVerifyForSettingChange){
        }
    }
    else if(self.passcodeType == PasscodeTypeChangePasscode)
    {
        if(self.currentWorkflowStep == WorkflowStepOne){
            self.lblInstruction.text = NSLocalizedString(EnterCurrentPasscodeLabel, nil);
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
                [self updateLayoutBasedOnWorkflowStep];
            }
        }
    }
    else if(self.passcodeType == PasscodeTypeVerify || self.passcodeType == PasscodeTypeVerifyForSettingChange){
        if([[PasscodeManager sharedManager] isPasscodeCorrect:self.passcodeEntered]){
            [_delegate didVerifyPasscode];
        }
        else{
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
            self.currentWorkflowStep = WorkflowStepOne;
            [self updateLayoutBasedOnWorkflowStep];
        }
        
    }

}


-(void)setDelegate:(id)newDelegate{
    _delegate = newDelegate;
}

@end
