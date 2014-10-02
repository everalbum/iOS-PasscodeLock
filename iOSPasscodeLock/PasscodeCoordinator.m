/*
 *  PasscodeManager.m
 *
 * Copyright (c) 2014 WordPress. All rights reserved.
 *
 * Licensed under GNU General Public License 2.0.
 * Some rights reserved. See license.txt
 */


#import "PasscodeCoordinator.h"
#import "FXKeychain.h"
#import <math.h>

@import LocalAuthentication;

static NSString * const PasscodeProtectionStatusKey = @"PasscodeProtectionEnabled";
static NSString * const TouchIdProtectionStatusKey = @"TouchIdProtectionStatusKey";
static NSString * const PasscodeKey = @"PasscodeKey";
static NSString * const PasscodeInactivityDuration = @"PasscodeInactivityDuration";
static NSString * const PasscodeInactivityStarted = @"PasscodeInactivityStarted";
static NSString * const PasscodeInactivityEnded = @"PasscodeInactivityEnded";

@interface PasscodeCoordinator ()

@property (nonatomic, strong) void (^setupCompletedBlock)(BOOL success);
@property (nonatomic, strong) void (^verificationCompletedBlock)(BOOL success);
@property (assign) BOOL passcodePresented;
@property (nonatomic, strong) UIWindow *passcodeWindow;

@end

@implementation PasscodeCoordinator

+ (PasscodeCoordinator *)sharedCoordinator {
    static PasscodeCoordinator *sharedCoordinator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCoordinator = [[self alloc] init];
    });
    return sharedCoordinator;
}

- (id)init {
    self = [super init];
    if(self) {
        _passcodePresented = NO;
    }
    return self;
}

- (void)dealloc {
    [self disableSubscriptions];
}

#pragma mark -
#pragma mark - Subscriptions management

- (void)activatePasscodeProtection {
    self.passcodeWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.passcodeWindow.windowLevel = UIWindowLevelAlert + 1;

    if([self isPasscodeProtectionOn]) {
        [self subscribeToNotifications];
    }
}

- (void)deactivatePasscodeProtection {
    [self disableSubscriptions];
}

- (void)subscribeToNotifications {
    [self disableSubscriptions];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleNotification:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleNotification:)
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleNotification:)
                                                 name: UIApplicationDidFinishLaunchingNotification
                                               object: nil];
}

- (void)disableSubscriptions {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidFinishLaunchingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)handleNotification:(NSNotification *)notification {
    if(notification.name == UIApplicationDidEnterBackgroundNotification) {
        [self dismissLockScreenAnimated:NO];
        [self startTrackingInactivity];
        if([self shouldLock]) {
            [self verifyPasscodeWithPasscodeType:PasscodeTypeVerify animated:NO withCompletion:nil];
        }
    }
    else if(notification.name == UIApplicationWillEnterForegroundNotification) {
        [self stopTrackingInactivity];
        if([self shouldLock]) {
            [self verifyPasscodeWithPasscodeType:PasscodeTypeVerify animated:NO withCompletion:nil];
        } else if (self.passcodePresented) {
            [self verifyWithTouchId];
        }
    }
    else if(notification.name == UIApplicationDidFinishLaunchingNotification) {
        [self stopTrackingInactivity];
        if([self shouldLock]) {
            [self verifyPasscodeWithPasscodeType:PasscodeTypeVerify animated:NO withCompletion:nil];
        }
    }

}

#pragma mark -
#pragma mark - TouchId

- (BOOL)isTouchIdAvailable {
    LAContext *context = [[LAContext alloc] init];
    NSError *error;
    
    return [context canEvaluatePolicy: LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
}

- (void) toggleTouchIdProtection:(BOOL)isOn {
    [[NSUserDefaults standardUserDefaults] setObject:(isOn ? @"YES" : @"NO") forKey:TouchIdProtectionStatusKey];
}

- (BOOL)isTouchIdProtectionOn {
    NSString *status = [[NSUserDefaults standardUserDefaults]stringForKey:TouchIdProtectionStatusKey];
    if(status) {
        return [status isEqual: @"YES"] ? YES : NO;
    }
    else{
        return NO;
    }
    return NO;
}

-(void)presentTouchIdWithCompletion:(void (^) (BOOL success)) completion {
    LAContext *context = [[LAContext alloc] init];
    
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
              localizedReason:@"Unlock Access"
                        reply:^(BOOL success, NSError *error) {
                            if(completion) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    completion(success);
                                });
                            }
                        }];
}

#pragma mark -
#pragma mark - PasscodeViewControllerDelegate methods

- (void)passcodeSetupCancelled {
    if(self.setupCompletedBlock) {
        self.setupCompletedBlock(NO);
        self.setupCompletedBlock = nil;
    }
    if(self.verificationCompletedBlock) {
        self.verificationCompletedBlock(NO);
        self.verificationCompletedBlock = nil;
    }
    [self dismissLockScreen];
}

- (void)didVerifyPasscode {
    if(self.verificationCompletedBlock) {
        self.verificationCompletedBlock(YES);
        self.verificationCompletedBlock = nil;
    }
    [self dismissLockScreen];
}

- (void)passcodeVerificationFailed{
    if(self.verificationCompletedBlock) {
        self.verificationCompletedBlock(NO);
        self.verificationCompletedBlock = nil;
    }
}

- (void)didSetupPasscode{
    [self togglePasscodeProtection:YES];
    if(self.setupCompletedBlock) {
        self.setupCompletedBlock(YES);
        self.setupCompletedBlock = nil;
    }
    [self dismissLockScreen];
}

#pragma mark -
#pragma mark - Workflow launchers

- (void)disablePasscodeProtectionWithCompletion:(void (^) (BOOL success)) completion {
    [self verifyPasscodeWithPasscodeType:PasscodeTypeVerifyForSettingChange withCompletion:^(BOOL success) {
        if(success) {
            [self togglePasscodeProtection:NO];
        }
        completion(success);
    }];
}

- (void)verifyPasscodeWithPasscodeType:(PasscodeType) passcodeType withCompletion:(void (^) (BOOL success)) completion {
    self.verificationCompletedBlock = completion;
    [self presentLockScreenWithPasscodeType:passcodeType animated:YES];
}

- (void)verifyPasscodeWithPasscodeType:(PasscodeType) passcodeType animated:(BOOL)animated withCompletion:(void (^) (BOOL success)) completion {
    self.verificationCompletedBlock = completion;
    [self presentLockScreenWithPasscodeType:passcodeType animated:animated];
}

- (void)presentLockScreenWithPasscodeType:(PasscodeType) passcodeType {
    [self presentLockScreenWithPasscodeType:passcodeType animated:YES];
}

- (void)presentLockScreenWithPasscodeType:(PasscodeType) passcodeType animated:(BOOL)animated {
    [self dismissLockScreenAnimated:NO];

    PasscodeViewController *pvc = [[PasscodeViewController alloc] initWithPasscodeType:passcodeType withDelegate:self];
    [self.passcodeWindow setRootViewController:pvc];
    
    if(animated) {
        [self.passcodeWindow setHidden:NO];
        
        CGRect screen = [UIScreen mainScreen].bounds;
        screen.origin.y = screen.size.height;
        self.passcodeWindow.frame = screen;
        
        [UIView animateWithDuration:0.5
                              delay:0.
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations: ^{
                             self.passcodeWindow.frame = [UIScreen mainScreen].bounds;
                         }
                         completion:^(BOOL finished){
                             if(!finished) {
                                 self.passcodeWindow.frame = [UIScreen mainScreen].bounds;
                             }
                         }];
    } else {
        [self.passcodeWindow setHidden:NO];
        self.passcodeWindow.frame = [UIScreen mainScreen].bounds;
    }
    
    self.passcodePresented = YES;
    
    if(passcodeType == PasscodeTypeVerify) {
        [self verifyWithTouchId];
    }
}

- (void)verifyWithTouchId {
    if([self isTouchIdProtectionOn]) {
        [self presentTouchIdWithCompletion:^(BOOL success) {
            if (success) {
                [self didVerifyPasscode];
            }
        }];
    }
}

- (void)setupNewPasscodeWithCompletion:(void (^)(BOOL success)) completion {
    [self setPasscodeInactivityDurationInMinutes:@0];
    self.setupCompletedBlock = completion;
    [self presentLockScreenWithPasscodeType:PasscodeTypeSetup];
    
}

- (void)changePasscodeWithCompletion:(void (^)(BOOL success)) completion {
    [self setPasscodeInactivityDurationInMinutes:[self getPasscodeInactivityDurationInMinutes]];
    self.setupCompletedBlock = completion;
    [self presentLockScreenWithPasscodeType:PasscodeTypeChangePasscode];
}

#pragma mark -
#pragma mark - Helper methods

- (BOOL)shouldLock{
    if(self.passcodePresented) {
        return NO;
    }
    
    NSNumber *inactivityLimit = [self getPasscodeInactivityDurationInMinutes];
    NSDate *inactivityStarted = [self getInactivityStartTime];
    NSDate *inactivityEnded = [self getInactivityEndTime];
    
    NSTimeInterval difference = [inactivityEnded timeIntervalSinceDate:inactivityStarted];
    if(isnan(difference)) {
        difference = 0;
    }
    NSInteger differenceInMinutes = difference / 60;
    
    if(differenceInMinutes < 0) { //Date/Time on device might be altered.
        differenceInMinutes = [inactivityLimit integerValue] + 1;
    }
    
    if([self isPasscodeProtectionOn] && ([inactivityLimit integerValue] <= differenceInMinutes)) {
        return YES;
    }
    return NO;
}

- (NSDate *)getInactivityStartTime {
    return [FXKeychain defaultKeychain][PasscodeInactivityStarted];
}

- (NSDate *)getInactivityEndTime {
    return [FXKeychain defaultKeychain][PasscodeInactivityEnded];
}

- (void)startTrackingInactivity {
    [FXKeychain defaultKeychain][PasscodeInactivityStarted] = [NSDate date];
}

- (void)stopTrackingInactivity {
    [FXKeychain defaultKeychain][PasscodeInactivityEnded] = [NSDate date];
}

- (void)dismissLockScreen {
    [self dismissLockScreenAnimated:YES];
}

- (void)dismissLockScreenAnimated:(BOOL)animated {
    if(self.passcodePresented) {
        self.passcodePresented = NO;
        
        if(animated) {
            self.passcodeWindow.frame = [UIScreen mainScreen].bounds;
            [self.passcodeWindow setHidden:NO];
            [UIView animateWithDuration:0.5
                                  delay:0.
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations: ^{
                                 CGRect screen = [UIScreen mainScreen].bounds;
                                 screen.origin.y = screen.size.height;
                                 self.passcodeWindow.frame = screen;
                             }
                             completion:^(BOOL finished){
                                 if(finished) {
                                     [self.passcodeWindow setHidden:YES];
                                 } else {
                                     self.passcodeWindow.frame = [UIScreen mainScreen].bounds;
                                     [self.passcodeWindow setHidden:NO];
                                 }
                             }];
        } else {
            [self.passcodeWindow setHidden:YES];
        }
    }
}

- (void)setPasscode:(NSString *)passcode {
    [FXKeychain defaultKeychain][PasscodeKey] = passcode;
}

- (BOOL)isPasscodeCorrect:(NSString *)passcode {
    return [[FXKeychain defaultKeychain][PasscodeKey] isEqualToString:passcode];
}

- (void) togglePasscodeProtection:(BOOL)isOn {
    if(isOn) {
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:PasscodeProtectionStatusKey];
        [self activatePasscodeProtection];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:PasscodeProtectionStatusKey];
        [self deactivatePasscodeProtection];
    }
}

- (void) setPasscodeInactivityDurationInMinutes:(NSNumber *) minutes {
    [FXKeychain defaultKeychain][PasscodeInactivityDuration] = minutes;
}

- (NSNumber *) getPasscodeInactivityDurationInMinutes {
    return   [NSNumber numberWithInteger:[[FXKeychain defaultKeychain][PasscodeInactivityDuration] integerValue]];
}

- (BOOL)isPasscodeProtectionOn{
    NSString *status = [[NSUserDefaults standardUserDefaults]stringForKey:PasscodeProtectionStatusKey];
    if(status) {
        return [status isEqual: @"YES"] ? YES : NO;
    }
    else{
        return NO;
    }
    return NO;
}

- (CATransition *)transitionAnimation:(NSString *)transitionType {
    CATransition* transition = [CATransition animation];
    transition.duration = 0.2;
    transition.type = transitionType;
    transition.subtype = kCATransitionFromBottom;
    return transition;
}

#pragma mark -
#pragma mark - Styling Getters

- (UIColor *)backgroundColor {
    if(_backgroundColor) {
        return _backgroundColor;
    }
    else{
        return [UIColor whiteColor];
    }
}

- (UIColor *)instructionsLabelColor {
    if(_instructionsLabelColor) {
        return _instructionsLabelColor;
    }
    else{
        return [UIColor blackColor];
    }
}

- (UIColor *)cancelOrDeleteButtonColor {
    if(_cancelOrDeleteButtonColor) {
        return _cancelOrDeleteButtonColor;
    }
    else{
        return [UIColor blackColor];
    }
}

- (UIColor *)passcodeViewFillColor {
    if(_passcodeViewFillColor) {
        return _passcodeViewFillColor;
    }
    else{
        return [UIColor blackColor];
    }
}

- (UIColor *)passcodeViewLineColor{
    if(_passcodeViewLineColor) {
        return _passcodeViewLineColor;
    }
    else{
        return [UIColor blackColor];
    }
}

- (UIColor *)errorLabelColor{
    if(_errorLabelColor) {
        return _errorLabelColor;
    }
    else{
        return [UIColor whiteColor];
    }
}

-(UIColor *)errorLabelBackgroundColor {
    if(_errorLabelBackgroundColor) {
        return _errorLabelBackgroundColor;
    }
    else{
        return [UIColor redColor];
    }
}

- (UIFont *)instructionsLabelFont {
    if(_instructionsLabelFont) {
        return _instructionsLabelFont;
    }
    else {
        return [UIFont systemFontOfSize:15];
    }
}

- (UIFont *)cancelOrDeleteButtonFont {
    if(_cancelOrDeleteButtonFont) {
        return _cancelOrDeleteButtonFont;
    }
    else {
        return [UIFont systemFontOfSize:15];
    }
}

- (UIFont *)errorLabelFont {
    if(_errorLabelFont) {
        return _errorLabelFont;
    }
    else {
        return [UIFont systemFontOfSize:15];
    }
}
- (PasscodeButtonStyleProvider *)buttonStyleProvider {
    if(_buttonStyleProvider) {
        return _buttonStyleProvider;
    }
    else {
        return [[PasscodeButtonStyleProvider alloc]init];
    }
}
- (UIImage *)backgroundImage {
    return _backgroundImage;
}

@end
