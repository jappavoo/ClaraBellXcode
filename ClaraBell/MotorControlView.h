//
//  MotorControlView.h
//  ClaraBell
//
//  Created by Jonathan Appavoo on 2/17/13.
//  Copyright (c) 2013 Jonathan Appavoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MotorControlView : UIImageView <UIGestureRecognizerDelegate>

@property (weak, nonatomic) NSOutputStream *motorOutputStream;
@end
