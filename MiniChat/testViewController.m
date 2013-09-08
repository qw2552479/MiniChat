//
//  testViewController.m
//  MiniChat
//
//  Created by aatc on 8/25/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import "testViewController.h"
#import "ActionSheetView.h"
@interface testViewController ()

@end

@implementation testViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    ActionSheetView *asvc = [[ActionSheetView alloc] init];
    [self.view addSubview:asvc];
    [asvc release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
