//
//  ViewController.m
//  ClaraBell
//
//  Created by Jonathan Appavoo on 2/13/13.
//  Copyright (c) 2013 Jonathan Appavoo. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

static inline double radians (double degrees) { return degrees * M_PI/180; }
#define LINELEN 80
uint8_t line[LINELEN];
int     linelen=0;
int d0,d1,d2,d3,prox;
enum {NONE=0, FORWARD, BACKWARD, LEFT, RIGHT} dir=NONE;
enum {S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10} speed=S0;

@interface ViewController ()

@end

@implementation ViewController

@synthesize serverAddr = _serverAddr;
@synthesize serverPort = _serverPort;
@synthesize inputStream = _inputStream;
@synthesize outputStream = _outputStream;
@synthesize state = _state;
@synthesize customDrawn = _customDrawn;

- (void)viewDidLoad
{
    [super viewDidLoad];
    d0 = rand() % 200;
    d1 = rand() % 200;
    d2 = rand() % 200;
    d3 = rand() % 100;
    prox = 0;
	// Do any additional setup after loading the view, typically from a nib.
    self.customDrawn = [CALayer layer];
    self.customDrawn.delegate = self;
    self.customDrawn.backgroundColor = [UIColor greenColor].CGColor;
    self.customDrawn.frame = CGRectMake(5, 20, 410, 410);
    self.customDrawn.shadowOffset = CGSizeMake(0, 3);
    self.customDrawn.shadowRadius = 5.0;
    self.customDrawn.shadowColor = [UIColor blackColor].CGColor;
    self.customDrawn.shadowOpacity = 0.8;
    self.customDrawn.cornerRadius = 10.0;
    self.customDrawn.borderColor = [UIColor whiteColor].CGColor;
    self.customDrawn.borderWidth = 2.0;
    self.customDrawn.masksToBounds = YES;
    [self.view.layer addSublayer:self.customDrawn];
    [self.customDrawn setNeedsDisplay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)connect:(id)sender {
    
    if (self.state == CONNECTED) return;
    
    if (self.state == DISCONNECTED) {
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
            self.state = CONNECTING;
            NSLog(@"connecting");
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.serverAddrField || theTextField == self.serverPortField) {
        [theTextField resignFirstResponder];
    }
    return YES;
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
	switch (streamEvent) {
            
		case NSStreamEventOpenCompleted:
        {
			NSLog(@"Stream opened");
            self.state = CONNECTED;
            NSString *msg = [[NSString alloc] initWithFormat:@"connected to %@:%@", self.serverAddr, self.serverPort];
            self.status.text = msg;

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
                            line[linelen]=buffer[i];
                            linelen++;
                            if (line[linelen-1]=='\n' || linelen==LINELEN-1) {
                                line[linelen]=0;
                                sscanf((const char *)line,"%d %d %d %d %d",
                                       &d0, &d1, &d2, &d3, &prox);
                                [self.customDrawn setNeedsDisplay];
#if 0
                                NSString *output = [[NSString alloc] initWithBytes:line length:linelen+1 encoding:NSASCIIStringEncoding];
                                
                                if (nil != output) {
                                    NSLog(@"server said: %@", output);
                                }
#endif
                                linelen=0;
                            }
                        }
                    }
                }
//                NSString *response  = [NSString stringWithFormat:@"hello\n"];
//                NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
//                [self.outputStream write:[data bytes] maxLength:[data length]];
//                NSLog(@"sent hello");
//                self.d0 = rand() % 200;
//                self.d1 = rand() % 200;
//                self.d2 = rand() % 200;
 //               self.d3 = rand() % 100;
                //               [self.customDrawn setNeedsDisplay];
            }
			break;
            
		case NSStreamEventErrorOccurred:
        {
			NSLog(@"Can not connect to the host!");
            self.state = DISCONNECTED;
            NSString *msg = [[NSString alloc] initWithFormat:@"FAILED to connect to %@:%@", self.serverAddr, self.serverPort];
            self.status.text = msg;
        }
			break;
            
		case NSStreamEventEndEncountered:
        {
            NSLog(@"Lost Connection host!");
            self.state = DISCONNECTED;
            NSString *msg = [[NSString alloc] initWithFormat:@"LOST connection to %@:%@", self.serverAddr, self.serverPort];
            self.status.text = msg;

        }
			break;
    
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"Has Space");
            break;
		default:
			NSLog(@"Unknown event: %i", streamEvent);
	}
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
    
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextFillRect(context, layer.bounds);
    
    
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 200, 200);
    CGContextAddArc(context, 200, 200, d0, radians(255), radians(290), 0);
    CGContextClosePath(context);
    CGContextFillPath(context);

    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 200, 200);
    CGContextAddArc(context, 200, 200, d1, radians(345), radians(15), 0);
    CGContextClosePath(context);
    CGContextFillPath(context);


    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 200, 200);
    CGContextAddArc(context, 200, 200, d2, radians(75), radians(105), 0);
    CGContextClosePath(context);
    CGContextFillPath(context);

    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 200, 200);
    CGContextAddArc(context, 200, 200, d3, radians(165), radians(195), 0);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    CGContextRestoreGState(context);
}

- (IBAction)ControlPan:(UIPanGestureRecognizer *)sender {
    if (self.state!=CONNECTED) return;
    NSLog(@"ControlPan: ");
    UIView *v = [sender view];
    CGPoint l = [sender locationInView:v];
    CGPoint t = [sender translationInView:v];
    UIGestureRecognizerState s = [sender state];
    
    switch (s) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"> Began:");
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
            NSLog(@"< Ended:");
                [self.outputStream write:(const uint8_t *)"MH\n" maxLength:3];
            dir=NONE; speed=S0;
            break;
        default:
            NSLog(@"state unknown %i: ",s);
    }
    NSLog(@"l:(%f,%f) t:(%f,%f) dir=%d\n", l.x, l.y, t.x, t.y, dir);

}
@end
