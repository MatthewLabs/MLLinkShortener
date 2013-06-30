//
//  ViewController.m
//  MLLinkShortener
//
//  Created by Matteo Del Vecchio on 30/06/13.
//  Copyright (c) 2013 Matteo Del Vecchio. All rights reserved.
//

#import "ViewController.h"
#import "ShortenerSelectorViewController.h"
#import "MLLinkShortener.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)chooseShortener:(id)sender
{
	ShortenerSelectorViewController *selector = [[ShortenerSelectorViewController alloc] initWithStyle:UITableViewStyleGrouped];
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:selector];
	[self presentViewController:navController animated:YES completion:nil];
}

-(IBAction)shortenURL:(id)sender
{
	NSString *link = self.URLField.text;
	
	MLLinkShortenerOption option = [[NSUserDefaults standardUserDefaults] integerForKey:@"selectedShortener"];
	
	MLLinkShortener *shortener = [MLLinkShortener prepareLink:link usingShortner:option];
	[shortener shortLinkWithOptions:nil success:^(NSURL *link) {
		self.resultLabel.text = [link absoluteString];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	} failure:^(NSError *error) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error.userInfo valueForKey:@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}];
}

@end
