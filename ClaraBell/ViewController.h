//
//  ViewController.h
//  ClaraBell
//
//  Created by Jonathan Appavoo on 2/13/13.
//  Copyright (c) 2013 Jonathan Appavoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITextFieldDelegate,NSStreamDelegate>

@property (weak, nonatomic) IBOutlet UITextField *serverPortField;
@property (weak, nonatomic) IBOutlet UITextField *serverAddrField;

@property (weak, nonatomic) IBOutlet UILabel *status;
@property (copy, nonatomic) NSString *serverAddr;
@property (copy, nonatomic) NSString *serverPort;
@property (nonatomic) enum { DISCONNECTED=0, CONNECTING, CONNECTED} state;
//@property (nonatomic) int d0, d1, d2, d3, prox;
@property (nonatomic) CALayer *customDrawn;
@property (weak, nonatomic) NSInputStream *inputStream;
@property (weak, nonatomic) NSOutputStream *outputStream;

- (IBAction)connect:(id)sender;
- (IBAction)ControlPan:(UIPanGestureRecognizer *)sender;


@end
