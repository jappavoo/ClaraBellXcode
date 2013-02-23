//
//  ViewController.m
//  ClaraBell
//
//  Created by Jonathan Appavoo on 2/13/13.
//  Copyright (c) 2013 Jonathan Appavoo. All rights reserved.
//

#import "ViewController.h"
#import "MotorControlView.h"
#import <QuartzCore/QuartzCore.h>
#include "ClaraBell.h"

#define CUSTOM_DRAW_BORDER 8
#define CUSTOM_DRAW_ORIGIN_X 50
#define CUSTOM_DRAW_ORIGIN_Y 20

static inline double radians (double degrees) { return degrees * M_PI/180; }

@interface ViewController ()

@end

@implementation ViewController

@synthesize serverAddr = _serverAddr;
@synthesize serverPort = _serverPort;
@synthesize sayString = _sayString;
@synthesize inputStream = _inputStream;
@synthesize outputStream = _outputStream;
@synthesize customDrawn = _customDrawn;
@synthesize leftWheelEncoderLabel = _leftWheelEncoderLabel;
@synthesize sayList = _sayList;
@synthesize sayListCursor = _sayListCursor;


- (void)viewDidLoad
{
    [super viewDidLoad];
    cb.d0 = CB_SENSOR_MAX_DISTANCE;
    cb.d1 = CB_SENSOR_MAX_DISTANCE;
    cb.d2 = CB_SENSOR_MAX_DISTANCE;
    cb.d3 = CB_SENSOR_MAX_DISTANCE;
    cb.prox = 0;
    

	// Do any additional setup after loading the view, typically from a nib.
    
    self.sayListCursor=0;
    self.sayList = [[NSMutableArray alloc] initWithCapacity:20];
    [self.sayList insertObject:@"What are you doing?" atIndex:0];
    [self.sayList insertObject:@"I am tired." atIndex:1];
 //   for (int i=0; i<self.sayList.count; i++) NSLog(@"SayList[%i]=%@", i, [self.sayList objectAtIndex:i]);
    self.sayField.text = [self.sayList objectAtIndex:self.sayListCursor];
    
    self.customDrawn = [CALayer layer];
    self.customDrawn.delegate = self;
    self.customDrawn.backgroundColor = [UIColor greenColor].CGColor;
    self.customDrawn.frame = CGRectMake(CUSTOM_DRAW_ORIGIN_X, CUSTOM_DRAW_ORIGIN_Y,
                                        2 * CB_SENSOR_MAX_DISTANCE+CUSTOM_DRAW_BORDER,
                                        2 * CB_SENSOR_MAX_DISTANCE+CUSTOM_DRAW_BORDER);
    self.customDrawn.shadowOffset = CGSizeMake(0, 3);
    self.customDrawn.shadowRadius = 5.0;
    self.customDrawn.shadowColor = [UIColor blackColor].CGColor;
    self.customDrawn.shadowOpacity = 0.8;
    self.customDrawn.cornerRadius = 10.0;
    self.customDrawn.borderColor = [UIColor whiteColor].CGColor;
    self.customDrawn.borderWidth = 2.0;
    self.customDrawn.masksToBounds = YES;

    [self.view.layer addSublayer:self.customDrawn];

    self.leftWheelEncoderLabel = [[CATextLayer alloc] init];
    self.leftWheelEncoderLabel.font=(__bridge CFTypeRef)(@"System");
    self.leftWheelEncoderLabel.fontSize=17;
    self.leftWheelEncoderLabel.frame = CGRectMake(5,0,100, 20);
    self.leftWheelEncoderLabel.string=[NSString stringWithFormat:@"%010d",cb.lencoder];
    self.leftWheelEncoderLabel.alignmentMode=kCAAlignmentLeft;
    self.leftWheelEncoderLabel.foregroundColor=[[UIColor blueColor] CGColor];
    [self.customDrawn addSublayer:self.leftWheelEncoderLabel];

    self.rightWheelEncoderLabel = [[CATextLayer alloc] init];
    self.rightWheelEncoderLabel.font=(__bridge CFTypeRef)(@"System");
    self.rightWheelEncoderLabel.fontSize=17;
    self.rightWheelEncoderLabel.frame = CGRectMake(305,0,100, 20);
    self.rightWheelEncoderLabel.string=[NSString stringWithFormat:@"%010d",cb.rencoder];
    self.rightWheelEncoderLabel.alignmentMode=kCAAlignmentRight;
    self.rightWheelEncoderLabel.foregroundColor=[[UIColor orangeColor] CGColor];
    [self.customDrawn addSublayer:self.rightWheelEncoderLabel];

    
    CGRect  viewRect = CGRectMake(480, 100, 529, 529);
    self.motorControlView = [[MotorControlView alloc] initWithFrame:viewRect];
    NSString *imgFilepath = [[NSBundle mainBundle] pathForResource:@"motionspectrum" ofType:@"png"];
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:imgFilepath];
    [self.motorControlView setImage:img];
    
    self.motorControlView.userInteractionEnabled=YES;
    [self.view addSubview:self.motorControlView];
    
    [self.customDrawn setNeedsDisplay];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)connect:(id)sender {
    
    if (cb.cstate == CONNECTED) return;
    
    if (cb.cstate == DISCONNECTED) {
        self.serverAddr = self.serverAddrField.text;
        self.serverPort = self.serverPortField.text;

        NSString *addrString = self.serverAddr;
        if ([addrString length]==0) return;
        
        NSString *portString = self.serverPort;
        if ([portString length]==0) return;
        NSString *msg = [[NSString alloc] initWithFormat:@"Connecting to %@:%@!",
                         addrString, portString];
        self.status.text = msg;

        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;
        NSScanner* scan = [NSScanner scannerWithString:portString];
        int port;
        if ([scan scanInt:&port]) {
            CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)addrString,
                                               port, &readStream, &writeStream);
            self.inputStream = (__bridge NSInputStream *)(readStream);
            self.outputStream = (__bridge NSOutputStream *)writeStream;
            [self.inputStream setDelegate:self];
            [self.outputStream setDelegate:self];
            [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [self.inputStream open];
            [self.outputStream open];
            self.motorControlView.motorOutputStream = self.outputStream;
            cb.cstate = CONNECTING;
//            NSLog(@"connecting");
        }
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.serverAddrField || theTextField == self.serverPortField
        || theTextField == self.sayField) {
        [theTextField resignFirstResponder];
    }
    return YES;
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
	switch (streamEvent) {
            
		case NSStreamEventOpenCompleted:
        {
//			NSLog(@"Stream opened");
            if (theStream==self.outputStream) {
              cb.cstate = CONNECTED;
              NSString *msg = [[NSString alloc] initWithFormat:@"connected to %@:%@", self.serverAddr, self.serverPort];
              self.status.text = msg;
              cb.lencoder++;
              self.leftWheelEncoderLabel.string=[NSString stringWithFormat:@"%010d",cb.lencoder];
                cb.rencoder--;
                self.rightWheelEncoderLabel.string=[NSString stringWithFormat:@"%010d",cb.rencoder];
            }

        }
			break;
		case NSStreamEventHasBytesAvailable:
            {
                uint8_t buffer[1024];
                int len,i;
                
                while ([self.inputStream hasBytesAvailable]) {
                    len = [self.inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        for (i=0; i<len; i++) {
                            cb.line[cb.linelen]=buffer[i];
                            cb.linelen++;
                            if (cb.line[cb.linelen-1]=='\n' || cb.linelen==CB_LINELEN-1) {
                                cb.line[cb.linelen]=0;
                                sscanf((const char *)cb.line,"%d %d %d %d %d",
                                       &cb.d0, &cb.d1, &cb.d2, &cb.d3, &cb.prox);
                                [self.customDrawn setNeedsDisplay];
                                cb.linelen=0;
                            }
                        }
                    }
                }
//                NSString *response  = [NSString stringWithFormat:@"hello\n"];
//                NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
//                [self.outputStream write:[data bytes] maxLength:[data length]];
//                NSLog(@"sent hello");
//                self.d0 = rand() % CB_SENSOR_MAX_DISTANCE;
//                self.d1 = rand() % CB_SENSOR_MAX_DISTANCE;
//                self.d2 = rand() % CB_SENSOR_MAX_DISTANCE;
 //               self.d3 = rand() % 100;
                //               [self.customDrawn setNeedsDisplay];
            }
			break;
            
		case NSStreamEventErrorOccurred:
        {
//			NSLog(@"Can not connect to the host!");
            cb.cstate = DISCONNECTED;
            cb.volumeInit = 0;
            NSString *msg = [[NSString alloc] initWithFormat:@"FAILED to connect to %@:%@", self.serverAddr, self.serverPort];
            self.status.text = msg;
        }
			break;
            
		case NSStreamEventEndEncountered:
        {
//            NSLog(@"Lost Connection host!");
            cb.cstate = DISCONNECTED;
            cb.volumeInit = 0;
            NSString *msg = [[NSString alloc] initWithFormat:@"LOST connection to %@:%@", self.serverAddr, self.serverPort];
            self.status.text = msg;

        }
			break;
    
        case NSStreamEventHasSpaceAvailable:
//            NSLog(@"Has Space");
            if (cb.volumeInit==0) {
               [self setVolume:self.volumeSlider];
                cb.volumeInit=1;
            }
            break;
		default:
			NSLog(@"Unknown event: %i", streamEvent);
	}
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
    CGPoint center;
    center.x = layer.bounds.size.width / 2;
    center.y = layer.bounds.size.height / 2;
    
     CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextFillRect(context, layer.bounds);
    
    
    CGContextSaveGState(context);
    
    if (cb.prox & 1<<CB_FRONT_PROX_BIT) CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
    else CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, center.x, center.y);
    CGContextAddArc(context, center.x, center.y, cb.d0, radians(255), radians(290), 0);
    CGContextClosePath(context);
    CGContextFillPath(context);

    if (cb.prox & 1<<CB_RIGHT_PROX_BIT) CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
    else CGContextSetFillColorWithColor(context, [UIColor orangeColor].CGColor);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, center.x, center.y);
    CGContextAddArc(context, center.x, center.y, cb.d1, radians(345), radians(15), 0);
    CGContextClosePath(context);
    CGContextFillPath(context);

    if (cb.prox & 1<<CB_BACK_PROX_BIT) CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
    else CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, center.x, center.y);
    CGContextAddArc(context, center.x, center.y, cb.d2, radians(75), radians(105), 0);
    CGContextClosePath(context);
    CGContextFillPath(context);

    if (cb.prox & 1<<CB_LEFT_PROX_BIT) CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
    else CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, center.x, center.y);
    CGContextAddArc(context, center.x, center.y, cb.d3, radians(165), radians(195), 0);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    CGContextRestoreGState(context);
}


#if 0
- (IBAction)ControlPan:(UIPanGestureRecognizer *)sender {
    if (self.state!=CONNECTED) return;
    NSLog(@"ControlPan: ");
    UIView *v = [sender view];
    CGPoint l = [sender locationInView:v];
    CGPoint t = [sender translationInView:v];
    UIGestureRecognizerState s = [sender state];
    
    switch (s) {
        case UIGestureRecognizerStateBegan:
//            NSLog(@"> Began:");
            dir=NONE; speed=S0;
//              [self.outputStream write:(const uint8_t *)"M2g\n" maxLength:4];
            break;
        case UIGestureRecognizerStateChanged:
            if (t.x<-40 && dir!=LEFT) {
                [self.outputStream write:(const uint8_t *)"Mlbrf\n" maxLength:6];
                dir=LEFT;
            }
            else if (t.x>40 && dir!=RIGHT) {
                [self.outputStream write:(const uint8_t *)"Mlfrb\n" maxLength:6];
                dir=RIGHT;
            }
            else if (t.y<0 && t.x<40 && t.x>-40 && dir!=FORWARD) {
                [self.outputStream write:(const uint8_t *)"Mf\n" maxLength:3];
                dir=FORWARD;
            }
            else if (t.y>0 && t.x<40 && t.x>-40 2`23&& dir!=BACKWARD) {
                [self.outputStream write:(const uint8_t *)"Mb\n" maxLength:3];
                dir=BACKWARD;
            }
            if (speed!=S3) {
              [self.outputStream write:(const uint8_t *)"M2g\n" maxLength:4];
              speed=S3;
            }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
//            NSLog(@"< Ended:");
                [self.outputStream write:(const uint8_t *)"MH\n" maxLength:3];
            dir=NONE; speed=S0;
            break;
        default:
            NSLog(@"state unknown %i: ",s);
    }
//    NSLog(@"l:(%f,%f) t:(%f,%f) dir=%d\n", l.x, l.y, t.x, t.y, dir);

}
#endif


- (IBAction)sayButton:(UIButton *)sender {
    if (cb.cstate != CONNECTED) return;
    unichar c=[sender.titleLabel.text characterAtIndex:0];
    uint8_t cmd[3]; cmd[0]='V'; cmd[1]=c;  cmd[2]='\n';
    [self.outputStream write:cmd  maxLength:3];
}

- (IBAction)sayString:(UIButton *)sender {
    self.sayString = self.sayField.text;
    NSString *str = self.sayString;
    if ([str length]==0) return;
    
    if (cb.cstate != CONNECTED) return;
    
    NSString *msg = [[NSString alloc] initWithFormat:@"V\"%@\n",
                     str];
    NSData *data = [msg dataUsingEncoding:NSASCIIStringEncoding];
    
    [self.outputStream write:data.bytes maxLength:data.length];
//    NSLog(@"%@ len=%i",msg, data.length);

}

- (IBAction)setVolume:(UISlider *)sender {
    if (cb.cstate != CONNECTED) return;
    NSString *msg = [[NSString alloc]
                        initWithFormat:@"Vv%f\n",sender.value];
    NSData *data = [msg dataUsingEncoding:NSASCIIStringEncoding];
    
    [self.outputStream write:data.bytes maxLength:data.length];

}

- (IBAction)clearSayField:(UIButton *)sender {
     if (self.sayListCursor!=-1 && self.sayListCursor!=self.sayList.count) {
         NSUInteger cursor = self.sayListCursor;
         [self upSayField:sender];
         [self.sayList removeObjectAtIndex:cursor];
    }
    self.sayField.text = nil;
}

- (IBAction)upSayField:(UIButton *)sender {
//   NSLog(@"up:start: %i %i",self.sayListCursor, self.sayList.count);
    
    if (self.sayField.text==nil) {
        if (self.sayListCursor==self.sayList.count) {
            self.sayListCursor=self.sayList.count-1;
        } 
    } else {
      NSString *str = [[NSString alloc] initWithString:self.sayField.text];
      if (self.sayListCursor==self.sayList.count || self.sayListCursor==-1) {
          if ([str length]==0) return;
          if (self.sayListCursor==-1) {
              [self.sayList insertObject:str atIndex:0];
              self.sayListCursor=0;
          } else {
              [self.sayList insertObject:str atIndex:self.sayList.count];
              self.sayListCursor--;
          }
      } else {
          self.sayListCursor--;
      }
    }
    if (self.sayListCursor==self.sayList.count || self.sayListCursor==-1) {
        self.sayField.text=nil;
    } else {
        self.sayField.text = [self.sayList objectAtIndex:self.sayListCursor];
    }
    
//    NSLog(@"up:start: %i %i",self.sayListCursor, self.sayList.count);
//    for (int i=0; i<self.sayList.count; i++) NSLog(@"SayList[%i]=%@", i, [self.sayList objectAtIndex:i]);
}

- (IBAction)downSayField:(UIButton *)sender {
//    NSLog(@"down:start: %i %i",self.sayListCursor, self.sayList.count);

    if (self.sayField.text==nil) {
        if (self.sayListCursor==-1) {
            self.sayListCursor=0;
        }
    } else {
        if (self.sayListCursor==self.sayList.count || self.sayListCursor==-1) {
          NSString *str = [[NSString alloc] initWithString:self.sayField.text];
          if ([str length]==0) return;
            if (self.sayListCursor==-1) {
                [self.sayList insertObject:str atIndex:0];
                self.sayListCursor=0;
            } else {
                [self.sayList insertObject:str atIndex:self.sayList.count];
                self.sayListCursor--;
            }
        } else {
            self.sayListCursor++;
        }
    }
    
    if (self.sayListCursor==self.sayList.count || self.sayListCursor==-1) {
        self.sayField.text = nil;
    } else {
        self.sayField.text = [self.sayList objectAtIndex:self.sayListCursor];
    }

//    NSLog(@"down:end: %i %i",self.sayListCursor, self.sayList.count);
//    for (int i=0; i<self.sayList.count; i++) NSLog(@"SayList[%i]=%@", i, [self.sayList objectAtIndex:i]);
}


@end
