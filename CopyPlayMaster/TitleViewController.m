//
//  TitleViewController.m
//  MediaPlayerTestSample
//
//  Created by user on 2015/03/23.
//  Copyright (c) 2015年 yamasaki. All rights reserved.
//

#import "TitleViewController.h"
#import "MainViewController.h"

@interface TitleViewController ()

@end

@implementation TitleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"TitleNew"] ) {
        MainViewController *mvc = (MainViewController*)[segue destinationViewController];
        mvc.mode = ModeNew;
    } else if ([segue.identifier isEqualToString:@"TitleSave"]){
        MainViewController *mvc = (MainViewController*)[segue destinationViewController];
        mvc.mode = ModeLoad;
    }
}


@end
