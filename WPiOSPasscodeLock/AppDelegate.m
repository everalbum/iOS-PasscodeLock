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
    // Override point for customization after application launch.
    
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
    
    [PasscodeManager sharedManager].buttonTitleFont = [UIFont fontWithName:@"Avenir-Book" size:35];
    [PasscodeManager sharedManager].instructionsLabelFont = [UIFont fontWithName:@"Avenir-Book" size:17];
    [PasscodeManager sharedManager].cancelOrDeleteButtonFont = [UIFont fontWithName:@"Avenir-Book" size:15];
    
    UIColor *iPhone5CBlue = [UIColor colorWithRed:0.275 green:0.671 blue:0.878 alpha:1.0];
    UIColor *iPhone5CGreen = [UIColor colorWithRed:0.631 green:0.91 blue:0.467 alpha:1.0];
    UIColor *iPhone5CWhite = [UIColor colorWithRed:0.961 green:0.957 blue:0.969 alpha:1.0];
    UIColor *iPhone5CPink = [UIColor colorWithRed:0.996 green:0.463 blue:0.478 alpha:1.0];
    UIColor *iPhone5CYellow = [UIColor colorWithRed:0.98 green:0.945 blue:0.537 alpha:1.0];
    UIColor *iPhone5SSpaceGrey = [UIColor colorWithRed:0.6 green:0.596 blue:0.608 alpha:1.0];
    UIColor *iPhone5SGold = [UIColor colorWithRed:0.831 green:0.773 blue:0.702 alpha:1.0];
    UIColor *iPhone5SSilver = [UIColor colorWithRed:0.843 green:0.851 blue:0.847 alpha:1.0];
    
    UIColor *blackColor = [UIColor blackColor];
    
    [PasscodeManager sharedManager].backgroundColor = iPhone5CPink;
    [PasscodeManager sharedManager].buttonHighlightedLineColor = iPhone5CPink;
    [PasscodeManager sharedManager].buttonHighlightedTitleColor = iPhone5CPink;
    
    [PasscodeManager sharedManager].buttonLineColor = iPhone5CYellow;
    [PasscodeManager sharedManager].buttonTitleColor = iPhone5CYellow;
    [PasscodeManager sharedManager].buttonHighlightedFillColor = iPhone5CYellow;
    [PasscodeManager sharedManager].instructionsLabelColor = iPhone5CYellow;
    [PasscodeManager sharedManager].cancelOrDeleteButtonColor = iPhone5CYellow;
    [PasscodeManager sharedManager].passcodeViewFillColor = iPhone5CYellow;
    [PasscodeManager sharedManager].passcodeViewLineColor = iPhone5CYellow;
    
    [PasscodeManager sharedManager].buttonFillColor = [UIColor clearColor];

}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
