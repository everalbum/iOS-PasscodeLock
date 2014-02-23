//
//  AppDelegate.m
//  WPiOSPasscodeLock
//
//  Created by Basar Akyelli on 2/14/14.
//  Copyright (c) 2014 Basar Akyelli. All rights reserved.
//

#import "AppDelegate.h"
#import "SettingsViewController.h" 
#import "PasscodeManager.h"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [[PasscodeManager sharedManager] activatePasscodeProtection];
    [self setPasscodeStyle];
    
    SettingsViewController *svc = [[SettingsViewController alloc]initWithStyle:UITableViewStyleGrouped];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:svc];
    
    self.window.rootViewController = nav;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    return YES;
}

-(void) setPasscodeStyle{
    
    UIColor *iPhone5CWhite = [UIColor colorWithRed:0.961 green:0.957 blue:0.969 alpha:1.0];
    UIColor *wpBlue = [UIColor colorWithRed:0.129 green:0.459 blue:0.608 alpha:1.0];
    UIColor *wpOrange = [UIColor colorWithRed:0.835 green:0.306 blue:0.129 alpha:1.0];
    
    PasscodeButtonStyleProvider *buttonStyleProvider = [[PasscodeButtonStyleProvider alloc]init];
    PasscodeStyle *style = [[PasscodeStyle alloc]init];
    style.lineColor = iPhone5CWhite;
    style.titleColor = iPhone5CWhite;
    style.fillColor = [UIColor clearColor];
    style.selectedFillColor = wpOrange;
    style.selectedLineColor = iPhone5CWhite;
    style.selectedTitleColor = iPhone5CWhite;
    style.titleFont = [UIFont fontWithName:@"Avenir-Book" size:35];
    
    [buttonStyleProvider addStyleForButton:PasscodeButtonAll stye:style];
    
    [PasscodeManager sharedManager].buttonStyleProvider = buttonStyleProvider;
    [PasscodeManager sharedManager].instructionsLabelFont = [UIFont fontWithName:@"Avenir-Book" size:17];
    [PasscodeManager sharedManager].cancelOrDeleteButtonFont = [UIFont fontWithName:@"Avenir-Book" size:15];
    [PasscodeManager sharedManager].errorLabelFont = [UIFont fontWithName:@"Avenir-Book" size:15];
    [PasscodeManager sharedManager].backgroundColor = wpBlue;
    [PasscodeManager sharedManager].backgroundImage = [UIImage imageNamed:@"background.jpeg"];
    [PasscodeManager sharedManager].appLockedCoverScreenBackgroundImage = [UIImage imageNamed:@"padlock.png"];
    [PasscodeManager sharedManager].appLockedCoverScreenBackgroundColor = wpBlue;
    [PasscodeManager sharedManager].instructionsLabelColor = iPhone5CWhite;
    [PasscodeManager sharedManager].cancelOrDeleteButtonColor = iPhone5CWhite;
    [PasscodeManager sharedManager].passcodeViewFillColor = wpOrange;
    [PasscodeManager sharedManager].passcodeViewLineColor = iPhone5CWhite;

//    UIColor *iPhone5CBlue = [UIColor colorWithRed:0.275 green:0.671 blue:0.878 alpha:1.0];
//    UIColor *iPhone5CGreen = [UIColor colorWithRed:0.631 green:0.91 blue:0.467 alpha:1.0];
//    UIColor *iPhone5CYellow = [UIColor colorWithRed:0.98 green:0.945 blue:0.537 alpha:1.0];
//    UIColor *iPhone5SSpaceGrey = [UIColor colorWithRed:0.6 green:0.596 blue:0.608 alpha:1.0];
//    UIColor *iPhone5SGold = [UIColor colorWithRed:0.831 green:0.773 blue:0.702 alpha:1.0];
//    UIColor *iPhone5SSilver = [UIColor colorWithRed:0.843 green:0.851 blue:0.847 alpha:1.0];
//    UIColor *iPhone5CPink = [UIColor colorWithRed:0.996 green:0.463 blue:0.478 alpha:1.0];

    }

@end
