//
//  ViewController.h
//  MLLinkShortener
//
//  Created by Matteo Del Vecchio on 30/06/13.
//  Copyright (c) 2013 Matteo Del Vecchio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *URLField;
@property (strong, nonatomic) IBOutlet UIButton *shortenButton;
@property (strong, nonatomic) IBOutlet UILabel *resultLabel;

-(IBAction)chooseShortener:(id)sender;
-(IBAction)shortenURL:(id)sender;

@end
