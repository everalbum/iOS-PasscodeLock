//
//  PasscodeManager.m
//  WPiOSPasscodeLock
//
//  Created by Basar Akyelli on 2/15/14.
//  Copyright (c) 2014 Basar Akyelli. All rights reserved.
//

#import "PasscodeManager.h"
#import "FXKeychain.h"
#import <math.h> 

static NSString * const kPasscodeProtectionStatusKey = @"PasscodeProtectionEnabled";
static NSString * const kPasscodeKey = @"PasscodeKey";
static NSString * const kPasscodeInactivityDuration = @"PasscodeInactivityDuration";
static NSString * const kPasscodeInactivityStarted = @"PasscodeInactivityStarted";
static NSString * const kPasscodeInactivityEnded = @"PasscodeInactivityEnded";

@interface PasscodeManager ()

@property (nonatomic, strong) void (^setupCompletedBlock)(BOOL success);
@property (nonatomic, strong) void (^verificationCompletedBlock)(BOOL success);
@property (nonatomic, strong) PasscodeViewController *passcodeViewController;
@property (nonatomic, strong) UIViewController *presentingViewController;
@end

@implementation PasscodeManager

+ (PasscodeManager *)sharedManager {
    static PasscodeManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

-(void) activatePasscodeProtection
{
    [self subscribeToNotifications];
}

-(void)subscribeToNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleNotification:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleNotification:)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
}

- (void) disablePasscodeProtectionWithCompletion:(void (^) (BOOL success)) completion
{
    [self verifyPasscodeWithPasscodeType:PasscodeTypeVerifyForSettingChange withCompletion:^(BOOL success) {
        if(success){
            [self togglePasscodeProtection:NO];
        }
        completion(success);
    }];
}


- (void)verifyPasscodeWithPasscodeType:(PasscodeType) passcodeType withCompletion:(void (^) (BOOL success)) completion
{
    self.verificationCompletedBlock = completion;
    [self presentLockScreenWithPasscodeType:passcodeType];
}

-(void)presentLockScreenWithPasscodeType:(PasscodeType) passcodeType
{
    self.passcodeViewController = [[PasscodeViewController alloc]initWithPasscodeType:passcodeType withDelegate:self];
   // UIWindow *mainWindow = [UIApplication sharedApplication].windows[0];
 //   [mainWindow addSubview: self.passcodeViewController.view];
   // [mainWindow.rootViewController addChildViewController: self.passcodeViewController];
    
    self.presentingViewController = [self topViewController];
    [self.presentingViewController presentViewController:self.passcodeViewController animated:NO completion:nil];

}


- (UIViewController *)topViewController{
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    
    if ([rootViewController.presentedViewController isMemberOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}








-(void)handleNotification:(NSNotification *)notification
{
    if(notification.name == UIApplicationDidEnterBackgroundNotification)
    {
        NSLog(@"Application did enter background");
        [self startTrackingInactivity];
    }
    else if(notification.name == UIApplicationDidBecomeActiveNotification)
    {
        NSLog(@"Application did become active");
        [self stopTrackingInactivity];
        
        if([self shouldLock]){
            [self verifyPasscodeWithPasscodeType:PasscodeTypeVerify withCompletion:nil];
        }
    }
}

-(BOOL) shouldLock
{
    NSNumber *inactivityLimit = [self getPasscodeInactivityDurationInMinutes];
    NSDate *inactivityStarted = [self getInactivityStartTime];
    NSDate *inactivityEnded = [self getInactivityEndTime];

    NSTimeInterval difference = [inactivityEnded timeIntervalSinceDate:inactivityStarted];
    if(isnan(difference)){
        difference = 0; 
    }
    NSInteger differenceInMinutes = difference / 60;
        
    if([self isPasscodeProtectionOn] && ([inactivityLimit integerValue] <= differenceInMinutes))
    {
        return YES;
    }
    return NO;
}
-(NSDate *)getInactivityStartTime
{
    return [FXKeychain defaultKeychain][kPasscodeInactivityStarted];
}
-(NSDate *)getInactivityEndTime
{
    return [FXKeychain defaultKeychain][kPasscodeInactivityEnded];
}

-(void)startTrackingInactivity
{
    [FXKeychain defaultKeychain][kPasscodeInactivityStarted] = [NSDate date];
}
-(void)stopTrackingInactivity
{
    [FXKeychain defaultKeychain][kPasscodeInactivityEnded] = [NSDate date];
}

-(void)setupNewPasscodeWithCompletion:(void (^)(BOOL success)) completion
{
    [self setPasscodeInactivityDurationInMinutes:@0];
    self.setupCompletedBlock = completion;
    [self presentLockScreenWithPasscodeType:PasscodeTypeSetup];

}
- (void) changePasscodeWithCompletion:(void (^)(BOOL success)) completion
{
    [self setPasscodeInactivityDurationInMinutes:[self getPasscodeInactivityDurationInMinutes]];
    self.setupCompletedBlock = completion;
    [self presentLockScreenWithPasscodeType:PasscodeTypeChangePasscode];
}

-(void)didSetupPasscode
{
    [self togglePasscodeProtection:YES];
    [self dismissLockScreen];
    if(self.setupCompletedBlock){
        self.setupCompletedBlock(YES);
    }
}

-(void)passcodeSetupCancelled
{
    if(self.setupCompletedBlock){
        self.setupCompletedBlock(NO);
    }
    
    if(self.verificationCompletedBlock){
        self.verificationCompletedBlock(NO);
    }
    [self dismissLockScreen];
}

- (void)dismissLockScreen
{
   // [self.passcodeViewController.view removeFromSuperview];
   // [self.passcodeViewController removeFromParentViewController];
    [self.passcodeViewController dismissViewControllerAnimated:NO completion:nil];
}

-(void)didVerifyPasscode
{
    if(self.verificationCompletedBlock){
        self.verificationCompletedBlock(YES);

    }
    [self dismissLockScreen];
}
-(void)passcodeVerificationFailed
{
    if(self.verificationCompletedBlock){
    self.verificationCompletedBlock(NO);
    }
}

- (void) setPasscode:(NSString *)passcode
{
    [FXKeychain defaultKeychain][kPasscodeKey] = passcode;
}

- (BOOL) isPasscodeCorrect:(NSString *)passcode
{
    bool result = [[FXKeychain defaultKeychain][kPasscodeKey] isEqualToString:passcode];
    if(result)
    {
        return YES;
    }
    else{
        return NO;
    }
    
}

- (void) togglePasscodeProtection:(BOOL)isOn
{
    if(isOn)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:kPasscodeProtectionStatusKey];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:kPasscodeProtectionStatusKey];
        
    }
}

- (void) setPasscodeInactivityDurationInMinutes:(NSNumber *) minutes
{
    [FXKeychain defaultKeychain][kPasscodeInactivityDuration] = minutes;
}

- (NSNumber *) getPasscodeInactivityDurationInMinutes
{
    return   [NSNumber numberWithInteger:[[FXKeychain defaultKeychain][kPasscodeInactivityDuration] integerValue]];
}

- (BOOL) isPasscodeProtectionOn
{
    NSString *status = [[NSUserDefaults standardUserDefaults]stringForKey:kPasscodeProtectionStatusKey];
    
    if(status)
    {
        if([status isEqual: @"YES"])
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    else{
        return NO;
    }
    
    return NO;
}

@end
