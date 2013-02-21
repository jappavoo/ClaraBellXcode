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
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UITextField *sayField;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;

@property (nonatomic) CALayer *customDrawn;
@property (nonatomic) MotorControlView *motorControlView;

@property (copy, nonatomic) NSString *serverAddr;
@property (copy, nonatomic) NSString *serverPort;
@property (weak, nonatomic) NSInputStream *inputStream;
@property (weak, nonatomic) NSOutputStream *outputStream;

@property (copy, nonatomic) NSString *sayString;
@property (nonatomic) NSMutableArray *sayList;
@property (nonatomic) NSUInteger sayListCursor;

- (IBAction)connect:(id)sender;
- (IBAction)sayButton:(UIButton *)sender;
- (IBAction)sayString:(UIButton *)sender;
- (IBAction)setVolume:(UISlider *)sender;

- (IBAction)clearSayField:(UIButton *)sender;
- (IBAction)upSayField:(UIButton *)sender;
- (IBAction)downSayField:(UIButton *)sender;


@end
