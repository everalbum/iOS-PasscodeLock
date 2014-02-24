//
//  WPiOSPasscodeLockTests.m
//  WPiOSPasscodeLockTests
//
//  Created by Basar Akyelli on 2/14/14.
//  Copyright (c) 2014 Basar Akyelli. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PasscodeManager.h"
#import "PasscodeButtonStyleProvider.h" 

@interface WPiOSPasscodeLockTests : XCTestCase

@end

@implementation WPiOSPasscodeLockTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void) testPasscodeVerification
{
    NSString *passcode = @"1111";
    [[PasscodeManager sharedManager] setPasscode:passcode];
    
    XCTAssertTrue([[PasscodeManager sharedManager] isPasscodeCorrect:passcode], @"Passcode was not set correctly.");
}

-(void) testPasscodeActivation
{
    [[PasscodeManager sharedManager] togglePasscodeProtection:NO];
    
    XCTAssertFalse([[PasscodeManager sharedManager] isPasscodeProtectionOn], @"Passcode protection activation does not function.");
}

- (void) testPasscodeInactivityDuration
{
    NSNumber *inactivityDuration = @1;
    [[PasscodeManager sharedManager] setPasscodeInactivityDurationInMinutes:inactivityDuration];
    
    XCTAssertTrue([[PasscodeManager sharedManager] getPasscodeInactivityDurationInMinutes] == inactivityDuration, @"Inactivity duration was not set correctly.");
}

- (void) testLockingDecision{
    NSNumber *inactivityDuration = @0;
    [[PasscodeManager sharedManager] togglePasscodeProtection:YES];
    [[PasscodeManager sharedManager] setPasscodeInactivityDurationInMinutes:inactivityDuration];
    
    XCTAssertTrue([[PasscodeManager sharedManager] shouldLock], @"Incorrect locking decision made.");
}

- (void) testPasscodeButtonStyleSetting
{
    PasscodeButtonStyleProvider *provider = [[PasscodeButtonStyleProvider alloc] init];
    PasscodeStyle *sampleStyle = [[PasscodeStyle alloc]init];
    [provider addStyleForButton:PasscodeButtonAll stye:sampleStyle];
    
    XCTAssertTrue([provider styleExistsForButton:PasscodeButtonAll], @"Passcode button style was not set.");
    XCTAssertTrue([provider styleForButton:PasscodeButtonAll] == sampleStyle, @"Passcode button style was not set.");
    XCTAssertFalse([provider styleExistsForButton:PasscodeButtonOne], @"styleExistsForButton: method does not return the expected value");
    XCTAssertTrue([provider styleForButton:PasscodeButtonOne], @"Default style for a button was not returned.");
}

@end
