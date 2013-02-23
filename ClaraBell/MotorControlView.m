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
#define XOFFDIV 15


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
        case DIR_NONE: return @"NONE";
        }
    return @"unknown Direction";
}

NSString *speedName(enum CB_SPEED s)
{
    switch (s) {
        case SNONE: return @"NONE";
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
    }
    return @"unknown Speed";
}

NSString *speedOffName(enum CB_SPEED_OFFSET o)
{
    switch(o) {
        case SOFFNONE: return @"SOFFNONE";
        case SOFF0: return @"SOFF0";
        case SOFF1: return @"SOFF1";
        case SOFF2: return @"SOFF2";
        case SOFF3: return @"SOFF3";
        case SOFF4: return @"SOFF4";
    }
    return @"unknown Speed Offset";
}

NSData *processLoc(enum CB_MOTION_TYPE t, CGPoint l, CGSize dim)
{
    int yval, xval;
    CGFloat yexp;
    enum CB_DIRECTION dir;
    enum CB_SPEED speed;
    enum CB_SPEED_OFFSET offset=0;
    
    yval = l.y / (dim.height/YDIV);
    xval = l.x / (dim.width/XDIV);
    
    yexp = (l.y<dim.height/2.0) ? dim.height/2.0 - l.y : l.y - dim.height/2.0;
    yexp = pow(yexp/(dim.height/2.0),1.5);

#if LINEAR_SPEED
    speed = (yval<YDIV/2) ? S9 - yval : yval-1 - S9;
#else
    speed = (int)(9.0*yexp);
#endif
    
//    NSLog(@"dim.h=%f l.y=%f yval=%d ly=%f v=%f : speed=%d lspeed=%d(%f)",
//          dim.height, l.y, yval, ly, v, speed, (int)(9.0*v), (double)(9.0*v));
    
    if (xval==1) {
        // STRAIGHT dir = FORWARD | BACKWARD
        if (yval<10) dir = FORWARD;
        else dir = BACKWARD;
    } else if (xval==0) {
        dir = LEFT;
    } else {
        dir = RIGHT;
    }
    offset = l.x/(dim.width/XOFFDIV)-((XOFFDIV/XDIV)*xval);

    // only send updates if we differ from the last values sent
    // we also don't send offset changes if we are going straight as
    // we know we are not using this feature yet.
    if (speed != cb.last_speed || dir != cb.last_dir ||
        ((dir==LEFT || dir==RIGHT) && offset != cb.last_offset)) {
        NSString *msg=[NSString stringWithFormat:@"M%c%c%u,%u\n", t,dir,speed,offset];
  //      NSLog(@"%@",msg);
        cb.last_speed = speed; cb.last_dir = dir; cb.last_offset = offset;
        return [msg dataUsingEncoding:NSASCIIStringEncoding];

    }
    return nil;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint p;
    Boolean inView;
//    NSLog(@"touchesBegan");

    for (UITouch *touch in touches) {
        p = [touch locationInView:self];
        inView = [self pointInside:p withEvent:event];
        if (cb.cstate == CONNECTED && inView) {
            cb.last_dir = DIR_NONE; cb.last_speed = SNONE; cb.last_offset = SOFFNONE;
            NSData *data=processLoc(BEGIN, p, self.bounds.size);
            if (data!=nil) [self.motorOutputStream write:data.bytes maxLength:data.length];
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
            NSData *data=processLoc(CHANGE, p, self.bounds.size);
            if (data!=nil) [self.motorOutputStream write:data.bytes maxLength:data.length];
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint p;
    Boolean inView;
//    NSLog(@"touchesEnded");
    for (UITouch *touch in touches) {
        p = [touch locationInView:self];
        inView = [self pointInside:p withEvent:event];
        
        if (cb.cstate==CONNECTED) [self.motorOutputStream write:(const uint8_t *)"ME\n" maxLength:3];
        cb.last_dir=DIR_NONE; cb.last_speed=SNONE; cb.last_offset = SOFFNONE;
//        NSLog(@"ME");
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"touchesCancelled");
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
