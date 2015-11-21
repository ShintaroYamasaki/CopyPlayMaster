//
//  InfoViewController.m
//  CopyTrainingPlayer
//
//  Created by user on 2015/04/07.
//  Copyright (c) 2015年 yamasaki. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initMenuBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //現在の向きを表すUIInterfaceOrientation取得
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    //向きに応じてレイアウトを設定する
    [self willRotateToInterfaceOrientation:orientation duration:.0f];
    //設定したレイアウトを反映する
    [self didRotateFromInterfaceOrientation:orientation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    [self getScreenSize:toInterfaceOrientation];
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self reloadMenuBar];
}

/// スクリーンサイズ取得
- (void) getScreenSize: (UIInterfaceOrientation) orientation {
    
    if ((orientation == UIInterfaceOrientationLandscapeLeft)
        || (orientation == UIInterfaceOrientationLandscapeRight)) {
        // 横
        // 短い方がheight, 長い方がwidth
        if ([[UIScreen mainScreen] bounds].size.width < [[UIScreen mainScreen] bounds].size.height) {
            _screenSize.height = [[UIScreen mainScreen] bounds].size.width;
            _screenSize.width = [[UIScreen mainScreen] bounds].size.height;
        } else {
            _screenSize.height = [[UIScreen mainScreen] bounds].size.height;
            _screenSize.width = [[UIScreen mainScreen] bounds].size.width;
        }
    } else {
        // 縦
        // 短い方がwidth, 長い方がheight
        if ([[UIScreen mainScreen] bounds].size.width < [[UIScreen mainScreen] bounds].size.height) {
            _screenSize.width = [[UIScreen mainScreen] bounds].size.width;
            _screenSize.height = [[UIScreen mainScreen] bounds].size.height;
        } else {
            _screenSize.width = [[UIScreen mainScreen] bounds].size.height;
            _screenSize.height = [[UIScreen mainScreen] bounds].size.width;
        }
    }
}

- (void) initMenuBar {
    // ボタンのフォント
    UIFont *font = [UIFont systemFontOfSize:MENU_FONT_SIZE];
    // ボタンのサイズ
    CGSize btnsize = CGSizeMake(MENU_COMPONENT_WIDTH, MENU_HEIGHT - BAR_MARGIN * 2);
    
    // ステータスバーが表示されているかどうか
    float statusheight = 0;
    if (![ UIApplication sharedApplication ].isStatusBarHidden) {
        CGSize statussize = [[UIApplication sharedApplication] statusBarFrame].size;
        if (statussize.width > statussize.height) {
            statusheight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        } else {
            statusheight = [[UIApplication sharedApplication] statusBarFrame].size.width;
        }
    }
    
    // メニュービュー
    _viewMenu = [[UIView alloc] initWithFrame:CGRectMake(0, statusheight, _screenSize.width, MENU_HEIGHT)];
    _viewMenu.backgroundColor = [UIColor blackColor];
    // レイヤーの作成
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    // レイヤーサイズをビューのサイズをそろえる
    gradient.frame = CGRectMake(0, 0, _viewMenu.frame.size.width, _viewMenu.frame.size.height);
    
    // 開始色と終了色を設定
    gradient.colors = @[
                        // 開始色
                        (id)[UIColor colorWithRed:.18 green:.18 blue:.18 alpha:1].CGColor,
                        // 終了色
                        (id)[UIColor colorWithRed:.10 green:.10 blue:.10 alpha:1].CGColor
                        ];
    [_viewMenu.layer insertSublayer:gradient atIndex:0];
    
    [self.view addSubview:_viewMenu];
    
    
    // backボタン
    _btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnBack.frame = CGRectMake(BAR_MARGIN * 3, BAR_MARGIN, btnsize.width, btnsize.height);
    // テキスト
    [_btnBack setTitle:@"Back" forState:UIControlStateNormal];
    [_btnBack.titleLabel setFont:font];
    [_btnBack setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    // バックイメージ
    [_btnBack setBackgroundImage:[UIImage imageNamed:@"frame-gray.png"] forState:UIControlStateNormal];
    // ターゲット
    [_btnBack addTarget:self action:@selector(onBackButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [_viewMenu addSubview:_btnBack];
    
    
}

- (void) reloadMenuBar {
    // ステータスバーが表示されているかどうか
    float statusheight = 0;
    if (![ UIApplication sharedApplication ].isStatusBarHidden) {
        CGSize statussize = [[UIApplication sharedApplication] statusBarFrame].size;
        if (statussize.width > statussize.height) {
            statusheight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        } else {
            statusheight = [[UIApplication sharedApplication] statusBarFrame].size.width;
        }
    }
    
    CGRect frame;
    
    // メニュービュー
    frame = _viewMenu.frame;
    frame.origin.y =  statusheight;
    frame.size.width = _screenSize.width;
    _viewMenu.frame = frame;
    CAGradientLayer *l = [_viewMenu.layer.sublayers objectAtIndex:0];
    frame = l.frame;
    frame.size.width = _screenSize.width;
    l.frame = frame;
}


- (void)onBackButton:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
