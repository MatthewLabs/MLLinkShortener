//
//  ShortenerSelectorViewController.m
//  MLLinkShortener
//
//  Created by Matteo Del Vecchio on 30/06/13.
//  Copyright (c) 2013 Matteo Del Vecchio. All rights reserved.
//

#import "ShortenerSelectorViewController.h"

@interface ShortenerSelectorViewController ()
@property (strong, nonatomic) NSArray *shorteners;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@end

@implementation ShortenerSelectorViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _shorteners = @[@"Bit.ly", @"Goo.gl", @"is.gd", @"Linkyy", @"v.gd"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.title = @"Choose Shortener";
	
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(saveShortener)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

-(void)saveShortener
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.shorteners count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    cell.textLabel.text = [self.shorteners objectAtIndex:indexPath.row];
	
	NSInteger shortener = [[NSUserDefaults standardUserDefaults] integerForKey:@"selectedShortener"];
	if (indexPath.row == shortener)
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
	
	[[NSUserDefaults standardUserDefaults] setInteger:indexPath.row forKey:@"selectedShortener"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
