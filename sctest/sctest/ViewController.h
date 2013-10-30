//
//  ViewController.h
//  sctest
//
//  Created by croath on 10/30/13.
//  Copyright (c) 2013 Croath. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
- (IBAction)nc2:(id)sender;
- (IBAction)c2:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *nc2Result;
@property (weak, nonatomic) IBOutlet UILabel *c2Result;
@end
