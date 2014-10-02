//
//  AppDelegate.m
//  WPiOSPasscodeLock
//
//  Created by Basar Akyelli on 2/14/14.
//  Copyright (c) 2014 Basar Akyelli. All rights reserved.
//

#import "AppDelegate.h"
#import "SettingsViewController.h" 
#import "PasscodeCoordinator.h"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //Activate protection
    [[PasscodeCoordinator sharedCoordinator] activatePasscodeProtection];
    
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
    
    UIColor *everalbumBlue = [UIColor colorWithRed:0.176 green:0.624 blue:0.933 alpha:1.0];
    
    PasscodeButtonStyleProvider *buttonStyleProvider = [[PasscodeButtonStyleProvider alloc]init];
    PasscodeButtonStyle *style = [[PasscodeButtonStyle alloc]init];
    style.lineColor = [UIColor whiteColor];
    style.titleColor = [UIColor whiteColor];
    style.fillColor = [UIColor clearColor];
    style.selectedFillColor = [UIColor whiteColor];
    style.selectedLineColor = [UIColor whiteColor];
    style.selectedTitleColor = everalbumBlue;
    style.titleFont = [UIFont fontWithName:@"Avenir-Book" size:35];
    
    [buttonStyleProvider addStyle:style forButton:PasscodeButtonTypeAll];
    
    [PasscodeCoordinator sharedCoordinator].buttonStyleProvider = buttonStyleProvider;
    [PasscodeCoordinator sharedCoordinator].instructionsLabelFont = [UIFont fontWithName:@"Avenir-Book" size:20];
    [PasscodeCoordinator sharedCoordinator].cancelOrDeleteButtonFont = [UIFont fontWithName:@"Avenir-Book" size:15];
    [PasscodeCoordinator sharedCoordinator].backgroundColor = everalbumBlue;
    [PasscodeCoordinator sharedCoordinator].logo = [UIImage imageNamed:@"wp_white.png"];
    [PasscodeCoordinator sharedCoordinator].instructionsLabelColor = [UIColor whiteColor];
    [PasscodeCoordinator sharedCoordinator].cancelOrDeleteButtonColor = [UIColor whiteColor];
    [PasscodeCoordinator sharedCoordinator].passcodeViewFillColor = [UIColor whiteColor];
    [PasscodeCoordinator sharedCoordinator].passcodeViewLineColor = [UIColor whiteColor];
}

@end
