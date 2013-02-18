//
//  ViewController.h
//  ClaraBell
//
//  Created by Jonathan Appavoo on 2/13/13.
//  Copyright (c) 2013 Jonathan Appavoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MotorControlView.h"

@interface ViewController : UIViewController <UITextFieldDelegate,NSStreamDelegate>

@property (weak, nonatomic) IBOutlet UITextField *serverPortField;
@property (weak, nonatomic) IBOutlet UITextField *serverAddrField;
@property (weak, nonatomic) IBOutlet UIImageView *controlView;
@property (weak, nonatomic) IBOutlet UILabel *status;

@property (nonatomic) CALayer *customDrawn;
@property (nonatomic) MotorControlView *motorControlView;

@property (copy, nonatomic) NSString *serverAddr;
@property (copy, nonatomic) NSString *serverPort;
@property (weak, nonatomic) NSInputStream *inputStream;
@property (weak, nonatomic) NSOutputStream *outputStream;


- (IBAction)connect:(id)sender;



@end
