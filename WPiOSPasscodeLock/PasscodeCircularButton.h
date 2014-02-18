//
//  CircleLineButton.h
//  ABPadLockScreenDemo
//
//  Created by Basar Akyelli on 2/15/14.
//  Copyright (c) 2014 Aron Bury. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PasscodeCircularButton : UIButton


- (id) initWithNumber:(NSString *)number
                frame:(CGRect)frame
            lineColor:(UIColor *) lineColor
           titleColor:(UIColor *) titleColor
            fillColor:(UIColor *) fillColor
    selectedLineColor:(UIColor *) selectedLineColor
   selectedTitleColor:(UIColor *) selectedTitleColor
    selectedFillColor:(UIColor *) selectedFillColor
                 font:(UIFont *) font; 
@end
