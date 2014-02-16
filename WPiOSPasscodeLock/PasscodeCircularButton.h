//
//  CircleLineButton.h
//  ABPadLockScreenDemo
//
//  Created by Basar Akyelli on 2/15/14.
//  Copyright (c) 2014 Aron Bury. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PasscodeCircularButton : UIButton

@property (nonatomic, strong) UIColor *lineColor;

- (void) drawCircular;

@end
