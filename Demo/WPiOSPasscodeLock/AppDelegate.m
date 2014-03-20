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
    
    
    //Activate protection
    [[PasscodeManager sharedManager] activatePasscodeProtection];
    
    //Set style
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
    PasscodeButtonStyle *style = [[PasscodeButtonStyle alloc]init];
    style.lineColor = iPhone5CWhite;
    style.titleColor = iPhone5CWhite;
    style.fillColor = [UIColor clearColor];
    style.selectedFillColor = wpOrange;
    style.selectedLineColor = iPhone5CWhite;
    style.selectedTitleColor = iPhone5CWhite;
    style.titleFont = [UIFont fontWithName:@"Avenir-Book" size:35];
    
    [buttonStyleProvider addStyle:style forButton:PasscodeButtonTypeAll];
    
    [PasscodeManager sharedManager].buttonStyleProvider = buttonStyleProvider;
    [PasscodeManager sharedManager].instructionsLabelFont = [UIFont fontWithName:@"Avenir-Book" size:20];
    [PasscodeManager sharedManager].cancelOrDeleteButtonFont = [UIFont fontWithName:@"Avenir-Book" size:15];
    [PasscodeManager sharedManager].backgroundColor = wpBlue;
    [PasscodeManager sharedManager].backgroundImage = [UIImage imageNamed:@"background.jpeg"];
    [PasscodeManager sharedManager].logo = [UIImage imageNamed:@"wp_white.png"];
    [PasscodeManager sharedManager].instructionsLabelColor = iPhone5CWhite;
    [PasscodeManager sharedManager].cancelOrDeleteButtonColor = iPhone5CWhite;
    [PasscodeManager sharedManager].passcodeViewFillColor = wpOrange;
    [PasscodeManager sharedManager].passcodeViewLineColor = iPhone5CWhite;
}

@end
