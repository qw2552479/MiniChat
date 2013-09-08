//
//  MainViewController.m
//  MiniChat
//
//  Created by aatc on 8/23/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import "MainViewController.h"
#import "LoginViewController.h"
#import "UserInfo.h"

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize loginUser;
+(MainViewController *) sharedMainViewController
{
    static MainViewController *mainViewController= nil;
    
    if (mainViewController == nil) {
        mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    }
    
    return mainViewController;
}

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
    self.mainNavigationController = [[[UINavigationController alloc] init] autorelease];
    [self.view addSubview:self.mainNavigationController.view];
    self.navigationController.navigationBarHidden = YES;
    
    if (self.loginUser == nil) {
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self.view addSubview:navi.view];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    self.mainNavigationController = nil;
    self.loginUser = nil;
    [super dealloc];
}

@end
