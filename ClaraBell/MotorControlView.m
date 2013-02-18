//
//  MotorControlView.m
//  ClaraBell
//
//  Created by Jonathan Appavoo on 2/17/13.
//  Copyright (c) 2013 Jonathan Appavoo. All rights reserved.
//

#import "MotorControlView.h"
#include "ClaraBell.h"

#define YDIV 20
#define XDIV 3


@implementation MotorControlView

@synthesize motorOutputStream = _motorOutputStream;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

NSString *dirName(enum CB_DIRECTION d)
{
    switch (d) {
        case FORWARD: return @"FORWARD";
        case BACKWARD: return @"BACKWARD";
        case LEFT: return @"LEFT";
        case RIGHT: return @"RIGHT";
        case NONE: return @"NONE";
        }
    return @"unknown Direction";
}

NSString *speedName(enum CB_SPEED s)
{
    switch (s) {
        case S0: return @"S0";
        case S1: return @"S1";
        case S2: return @"S2";
        case S3: return @"S3";
        case S4: return @"S4";
        case S5: return @"S5";
        case S6: return @"S6";
        case S7: return @"S7";
        case S8: return @"S8";
        case S9: return @"S9";
        case S10: return @"S10";
    }
    return @"unknown Speed";
}

Boolean processLoc(CGPoint l, CGSize dim)
{
    int yval, xval;
    enum CB_DIRECTION dir;
    enum CB_SPEED speed;
    Boolean update=NO;
    
    yval = l.y / (dim.height/YDIV);
    xval = l.x / (dim.width/XDIV);
    
    speed = (yval<YDIV/2) ? S10 - yval : yval - S9;
    
    if (xval==1) {
        // STRAIGHT dir = FORWARD | BACKWARD
        if (yval<10) dir = FORWARD;
        else dir = BACKWARD;
    } else if (xval==0) {
        dir = LEFT;
    } else {
        dir = RIGHT;
    }
    
    if (speed != cb.speed) {
        cb.speed = speed;
        update=YES;
    }
    
    if (dir != cb.dir) {
        cb.dir = dir;
        update=YES;
    }
   
    if (update) {
    NSLog(@"l.x=%f l.y=%f dim.w=%f dim.h=%f yval=%i xval=%i dir=%i S10=%@"
          " speed=%i speed=%@",
          l.x, l.y, dim.width, dim.height, yval, xval,
          dir, dirName(dir), speed, speedName(speed));
    }
    return update;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint p;
    Boolean inView;
    NSLog(@"touchesBegan");

    for (UITouch *touch in touches) {
        p = [touch locationInView:self];
        inView = [self pointInside:p withEvent:event];
        if (cb.cstate == CONNECTED && inView) {
            cb.dir=NONE; cb.speed=S0;
            processLoc(p, self.bounds.size);
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
   CGPoint p;
   Boolean inView;
 //   NSLog(@"touchesMoved");

    for (UITouch *touch in touches) {
        p = [touch locationInView:self];
        inView = [self pointInside:p withEvent:event];
        if (cb.cstate == CONNECTED && inView) {
            processLoc(p, self.bounds.size);
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint p;
    Boolean inView;
    NSLog(@"touchesEnded");
    for (UITouch *touch in touches) {
        p = [touch locationInView:self];
        inView = [self pointInside:p withEvent:event];
        
        if (cb.cstate==CONNECTED) [self.motorOutputStream write:(const uint8_t *)"MH\n" maxLength:3];
        cb.dir=NONE; cb.speed=S0;
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesCancelled");
    [self touchesEnded:touches withEvent:event];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
