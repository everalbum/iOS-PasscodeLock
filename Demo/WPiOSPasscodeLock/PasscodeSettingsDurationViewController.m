//
//  PasscodeSettingsDurationViewController.m
//  WPiOSPasscodeLock
//
//  Created by Basar Akyelli on 2/14/14.
//  Copyright (c) 2014 Basar Akyelli. All rights reserved.
//

#import "PasscodeSettingsDurationViewController.h"
#import "PasscodeCoordinator.h" 

@interface PasscodeSettingsDurationViewController ()

@end

@implementation PasscodeSettingsDurationViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

}


#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    
    NSString *cellText = self.durations[indexPath.row];
    
    if([cellText isEqualToString:self.psvc.passcodeDuration])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    cell.textLabel.text = cellText;

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.psvc.passcodeDuration = self.durations[indexPath.row];
    [[PasscodeCoordinator sharedCoordinator] setPasscodeInactivityDurationInMinutes:self.durationMinutes[indexPath.row]];
    [self.psvc reloadTableView];
    [self.navigationController popViewControllerAnimated:YES];
    
}



@end
