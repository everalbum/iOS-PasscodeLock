//
//  PasscodeCircularButton.m
//  WPiOSPasscodeLock
//
//  Created by Basar Akyelli on 2/15/14.
//  Copyright (c) 2014 Basar Akyelli. All rights reserved.
//

#import "PasscodeCircularButton.h"

@interface PasscodeCircularButton ()

@property (nonatomic, strong) CAShapeLayer *circleLayer;
@end

@implementation PasscodeCircularButton


- (void) drawCircular
{

    [self setTitleColor:_lineColor forState:UIControlStateNormal];
    self.circleLayer = [CAShapeLayer layer];
    [self.circleLayer setBounds:CGRectMake(0.0f, 0.0f, [self bounds].size.width, [self bounds].size.height)];
    [self.circleLayer setPosition:CGPointMake(CGRectGetMidX([self bounds]),CGRectGetMidY([self bounds]))];
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [self.circleLayer setPath:[path CGPath]];
    [self.circleLayer setStrokeColor:[_lineColor CGColor]];
    [self.circleLayer setLineWidth:0.5f];
    [self.circleLayer setFillColor:[[UIColor clearColor] CGColor]];
    [[self layer] addSublayer:self.circleLayer];
}

- (void)setHighlighted:(BOOL)highlighted
{
    if (highlighted)
    {
        self.titleLabel.textColor = [UIColor whiteColor];
        [self.circleLayer setFillColor:self.lineColor.CGColor];
    }
    else
    {
        [self.circleLayer setFillColor:[UIColor clearColor].CGColor];
        self.titleLabel.textColor = self.lineColor;
    }
}
@end