//
//  PasscodeManager.h
//  WPiOSPasscodeLock
//
//  Created by Basar Akyelli on 2/15/14.
//  Copyright (c) 2014 Basar Akyelli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PasscodeViewController.h" 

@interface PasscodeManager : NSObject <PasscodeViewControllerDelegate> 

+ (PasscodeManager *)sharedManager;

- (void) activatePasscodeProtection;
- (void) setupNewPasscodeWithCompletion:(void (^)(BOOL success)) completion;
- (void) changePasscodeWithCompletion:(void (^)(BOOL success)) completion;
- (void) didSetupPasscode;
- (void) setPasscode:(NSString *)passcode;
- (void) togglePasscodeProtection:(BOOL)isOn;
- (BOOL) isPasscodeProtectionOn;
- (BOOL) isPasscodeCorrect:(NSString *)passcode;
- (void) disablePasscodeProtectionWithCompletion:(void (^) (BOOL success)) completion;
- (void) setPasscodeInactivityDurationInMinutes:(NSNumber *) minutes;
- (NSNumber *) getPasscodeInactivityDurationInMinutes;

@property (strong, nonatomic) UIColor *backgroundColor;
@property (strong, nonatomic) UIColor *buttonLineColor;
@property (strong, nonatomic) UIColor *buttonTitleColor;
@property (strong, nonatomic) UIColor *buttonFillColor;
@property (strong, nonatomic) UIColor *buttonHighlightedLineColor;
@property (strong, nonatomic) UIColor *buttonHighlightedTitleColor;
@property (strong, nonatomic) UIColor *buttonHighlightedFillColor;
@property (strong, nonatomic) UIColor *instructionsLabelColor;
@property (strong, nonatomic) UIColor *cancelOrDeleteButtonColor;
@property (strong, nonatomic) UIColor *passcodeViewLineColor;
@property (strong, nonatomic) UIColor *passcodeViewFillColor; 
@property (strong, nonatomic) UIFont *buttonTitleFont;
@property (strong, nonatomic) UIFont *instructionsLabelFont;
@property (strong, nonatomic) UIFont *cancelOrDeleteButtonFont;



@end
