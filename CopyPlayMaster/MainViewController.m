//
//  ViewController.m
//  MediaPlayerTestSample
//
//  Created by user on 2014/12/19.
//  Copyright (c) 2014年 yamasaki. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController () {
    
}

@end

@implementation MainViewController

#pragma mark - View
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // スリープさせない
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [self getScreenSize:[UIApplication sharedApplication].statusBarOrientation];
    
    [self initAdBanner];
    
    [self initMenuBar];
    [self initControlBar];
    [self initMusicPlayerView];
    
    [self reset];
    
    // 各種フラグの初期化
    [self setIsSilent:NO];
    
    // ボリュームバーの設定
//    _viewVolume.backgroundColor = [UIColor clearColor];
//    _sldVolume = [[MPVolumeView alloc] initWithFrame: CGRectMake(0, 0, _viewVolume.frame.size.width, _viewVolume.frame.size.height)];
//    [_viewVolume addSubview: _sldVolume];
    
    // プロダクトマネージャー
    _productManager = [ProductManager sharedInstance];
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //現在の向きを表すUIInterfaceOrientation取得
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    //向きに応じてレイアウトを設定する
    [self willRotateToInterfaceOrientation:orientation duration:.0f];
    //設定したレイアウトを反映する
    [self didRotateFromInterfaceOrientation:orientation];
    
    // 初回表示
    if (_mode != ModeNone) {
        // 起動時に表示させる画面
        if (_mode == ModeNew) {
            // 選曲
            // ステータスバーの色
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            [self onNewButton:nil];
        } else if (_mode == ModeLoad) {
            // 保存データのロード
            [self onOpenButton:nil];
        }
        
        _mode = ModeNone;
    } else {
        // ステータスバーの色
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    
    // フレームの更新
    if (_adBannerView.hidden != _productManager.isRemoveAd) {
        [self reloadMenuBarFrame];
        [self reloadControlBarFrame];
        [self reloadMusicPlayerViewFrame];
    }
    
    // App課金購入状況の反映
    _adBannerView.hidden = _productManager.isRemoveAd;
    _stpSpeed.enabled = _productManager.isSpeedChange;
    _lblSpeed.enabled = _productManager.isSpeedChange;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
//    if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
//        || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
//        
//    } else {
//    
//    }
    
    [self getScreenSize:toInterfaceOrientation];
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self reloadAdBanner];
    [self reloadMenuBarFrame];
    [self reloadControlBarFrame];
    [self reloadMusicPlayerViewFrame];
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

- (void) setIsSilent:(BOOL)isSilent {
    _isSilent = isSilent;
    
    // サイレントフラグ状況の反映
    if (!isSilent) {
//        [_btnSilent setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnSilent setBackgroundColor:[UIColor clearColor]];
        [_btnSilent setBackgroundImage:[UIImage imageNamed:@"silent-gray.png"] forState:UIControlStateNormal];
    } else {
//        _btnSilent.backgroundColor = [UIColor cyanColor];
        [_btnSilent setBackgroundColor:[UIColor colorWithRed:0 green:95 blue:95 alpha:0.1
                                        ]];
        [_btnSilent setBackgroundImage:[UIImage imageNamed:@"silent-blue.png"] forState:UIControlStateNormal];
    }
}

/// リセット処理
- (void) reset {
    // 波形データ初期化
    _musicPlayerView.viewWaveImage.image = nil;
    
    // 停止
    [self playerStop];
    
    [_musicPlayerView removeAllSilentArea];
    
    // 音楽プレイヤーの初期化
    if (_musicPlayer != nil) _musicPlayer = nil;
    
    // ラベルの初期化
    _lblSong.text = @"";
    _lblTime.text = @"";
    _lblSpeed.text = @"Speed  x1.0";
    
    _musicPlayerView.hidden = YES;
}

#pragma mark - Menu Bar
/// メニューバーの設定
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
    [self initMenuViewWithFrame:CGRectMake(0, statusheight, _screenSize.width, MENU_HEIGHT)];
    // Newボタン
    [self initNewButtonWithFrame:CGRectMake(BAR_MARGIN * 3, BAR_MARGIN, btnsize.width, btnsize.height) Font:font];
    // Saveボタン
    [self initSaveButtonWithFrame:CGRectMake(BAR_MARGIN + _btnNew.frame.origin.x + _btnNew.frame.size.width, BAR_MARGIN, btnsize.width, btnsize.height) Font:font];
    // Openボタン
    [self initOpenButtonWithFrame:CGRectMake(BAR_MARGIN + _btnSave.frame.origin.x + _btnSave.frame.size.width, BAR_MARGIN, btnsize.width, btnsize.height) Font:font];
    // Shopボタン
    [self initShopButtonWithFrame:CGRectMake(BAR_MARGIN + _btnOpen.frame.origin.x + _btnOpen.frame.size.width, BAR_MARGIN, btnsize.width, btnsize.height) Font:font];
    // Helpボタン
    [self initHelpButtonWithFrame:CGRectMake(_viewMenu.frame.size.width - BAR_MARGIN * 2 - btnsize.height, BAR_MARGIN, btnsize.height, btnsize.height) Font:[UIFont systemFontOfSize:20]];
    // サイレントボタン
    [self initSilentButtonWithFrame:CGRectMake(_btnHelp.frame.origin.x - BAR_MARGIN * 2 - BTNSILENT_WIDTH, BAR_MARGIN, BTNSILENT_WIDTH, btnsize.height) Font:font];
}

/// メニューバーのフレーム更新
- (void) reloadMenuBarFrame {
    // ボタンのサイズ
    CGSize btnsize = CGSizeMake(MENU_COMPONENT_WIDTH, MENU_HEIGHT - BAR_MARGIN * 2);
    
    CGRect frame;
    
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
    frame = _viewMenu.frame;
    frame.origin.y =  statusheight;
    frame.size.width = _screenSize.width;
    _viewMenu.frame = frame;
    CAGradientLayer *l = [_viewMenu.layer.sublayers objectAtIndex:0];
    frame = l.frame;
    frame.size.width = _screenSize.width;
    l.frame = frame;
    // ヘルプボタン
    frame = _btnHelp.frame;
    frame.origin.x = _viewMenu.frame.size.width - BAR_MARGIN * 2 - btnsize.height;
    _btnHelp.frame = frame;
    // サイレントボタン
    frame = _btnSilent.frame;
    frame.origin.x = _btnHelp.frame.origin.x - BAR_MARGIN * 2 - BTNSILENT_WIDTH;
    _btnSilent.frame = frame;
}

///　メニュービューの初期化
- (void) initMenuViewWithFrame: (CGRect) frame {
    
    _viewMenu = [[UIView alloc] initWithFrame:frame];
    
    // レイヤーの作成
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    // レイヤーサイズをビューのサイズをそろえる
    gradient.frame = _viewMenu.bounds;
    
    // 開始色と終了色を設定
    gradient.colors = @[
                        // 開始色
                        (id)[UIColor colorWithRed:.18 green:.18 blue:.18 alpha:1].CGColor,
                        // 終了色
                        (id)[UIColor colorWithRed:.10 green:.10 blue:.10 alpha:1].CGColor
                        ];
    [_viewMenu.layer insertSublayer:gradient atIndex:0];
    
    [self.view addSubview:_viewMenu];
}

/// Newボタンの初期化
- (void) initNewButtonWithFrame: (CGRect) frame Font: (UIFont *) font {
    _btnNew = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnNew.frame = frame;
    
    // テキスト
    [_btnNew setTitle:@"New" forState:UIControlStateNormal];
    [_btnNew.titleLabel setFont:font];
    [_btnNew setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    // バックイメージ
    [_btnNew setBackgroundImage:[UIImage imageNamed:@"frame-gray.png"] forState:UIControlStateNormal];
    // ターゲット
    [_btnNew addTarget:self action:@selector(onNewButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [_viewMenu addSubview:_btnNew];
}

/// Saveボタンの初期化
- (void) initSaveButtonWithFrame: (CGRect) frame Font: (UIFont *) font {
    _btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnSave.frame = frame;
    
    // テキスト
    [_btnSave setTitle:@"Save" forState:UIControlStateNormal];
    [_btnSave.titleLabel setFont:font];
    [_btnSave setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    // バックイメージ
    [_btnSave setBackgroundImage:[UIImage imageNamed:@"frame-gray.png"] forState:UIControlStateNormal];
    // ターゲット
    [_btnSave addTarget:self action:@selector(onSaveButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [_viewMenu addSubview:_btnSave];
    
    // 初めは無効化
    _btnSave.enabled = NO;
}

/// Openボタンの初期化
- (void) initOpenButtonWithFrame: (CGRect) frame Font: (UIFont *) font {
    _btnOpen = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnOpen.frame = frame;
    
    // テキスト
    [_btnOpen setTitle:@"Open" forState:UIControlStateNormal];
    [_btnOpen.titleLabel setFont:font];
    [_btnOpen setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    // バックイメージ
    [_btnOpen setBackgroundImage:[UIImage imageNamed:@"frame-gray.png"] forState:UIControlStateNormal];
    // ターゲット
    [_btnOpen addTarget:self action:@selector(onOpenButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [_viewMenu addSubview:_btnOpen];
}

/// Shopボタンの初期化
- (void) initShopButtonWithFrame: (CGRect) frame Font: (UIFont *) font {
    _btnShop = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnShop.frame = frame;
    
    // テキスト
    [_btnShop setTitle:@"Shop" forState:UIControlStateNormal];
    [_btnShop.titleLabel setFont:font];
    [_btnShop setTitleColor:[UIColor colorWithRed:.17 green:.57 blue:.85 alpha:1.0] forState:UIControlStateNormal];
    // バックイメージ
    [_btnShop setBackgroundImage:[UIImage imageNamed:@"frame-blue.png"] forState:UIControlStateNormal];
    // ターゲット
    [_btnShop addTarget:self action:@selector(onShopButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [_viewMenu addSubview:_btnShop];
}

/// サイレントボタンの初期化
- (void) initSilentButtonWithFrame: (CGRect) frame Font: (UIFont *) font {
    _btnSilent = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnSilent.frame = frame;
    
    // テキスト
    [_btnSilent setTitle:@"Silent" forState:UIControlStateNormal];
    [_btnSilent.titleLabel setFont:font];
    [_btnSilent setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    // バックイメージ
    [_btnSilent setBackgroundImage:[UIImage imageNamed:@"silent-gray.png"] forState:UIControlStateNormal];
    // ターゲット
    [_btnSilent addTarget:self action:@selector(onSilentButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [_viewMenu addSubview:_btnSilent];
}

/// ヘルプボタンの初期化
- (void) initHelpButtonWithFrame: (CGRect) frame Font: (UIFont *) font {
    _btnHelp = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnHelp.frame = frame;
    
    // テキスト
    [_btnHelp setTitle:@"?" forState:UIControlStateNormal];
    [_btnHelp.titleLabel setFont:font];
    [_btnHelp setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    // バックイメージ
    [_btnHelp setBackgroundImage:[UIImage imageNamed:@"help.png"] forState:UIControlStateNormal];
    // ターゲット
    [_btnHelp addTarget:self action:@selector(onHelpButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [_viewMenu addSubview:_btnHelp];
}

#pragma mark - Control Bar
/// コントロールバーの設定
- (void) initControlBar {
    // 広告バナーが表示されているかどうか
    float adheight = 0;
    if (!_productManager.isRemoveAd) {
        adheight = _adBannerView.frame.size.height;
    }
    
    //現在の向きを表すUIInterfaceOrientation取得
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    float leftmargin = 0;
    if ((orientation == UIInterfaceOrientationLandscapeLeft)
        || (orientation == UIInterfaceOrientationLandscapeRight)) {
        leftmargin = _screenSize.width / 2 + CONTROL_HEIGHT/ 2 + BAR_MARGIN * 2 + CONTROL_HEIGHT;
    } else {
        leftmargin =(_screenSize.width - _viewSpeed.frame.size.width - _viewSpeed.frame.origin.x) / 2 + _viewSpeed.frame.size.width + _viewSpeed.frame.origin.x + CONTROL_HEIGHT/ 2 + BAR_MARGIN * 2 + CONTROL_HEIGHT;
    }
    
    // コントロールビュー
    [self initControlViewWithFrame:CGRectMake(0, _screenSize.height - CONTROL_HEIGHT - adheight, _screenSize.width, CONTROL_HEIGHT)];
    // スピードビュー
    [self initSpeedViewWithFrame:CGRectMake(BAR_MARGIN * 3, BAR_MARGIN, 100, CONTROL_HEIGHT - BAR_MARGIN * 2) Font:[UIFont systemFontOfSize:10]];
    // 停止ボタン
    [self initStopButtonWithFrame:CGRectMake(leftmargin - CONTROL_HEIGHT, 0, CONTROL_HEIGHT, CONTROL_HEIGHT)];
    // 再生ボタン
    [self initPlayButtonWithFrame:CGRectMake(_btnStop.frame.origin.x - BAR_MARGIN * 2 - CONTROL_HEIGHT, 0, CONTROL_HEIGHT, CONTROL_HEIGHT)];
    // 巻き戻しボタン
    [self initRewindButtonWithFrame:CGRectMake(_btnPlay.frame.origin.x - CONTROL_HEIGHT - BAR_MARGIN * 2, 0, CONTROL_HEIGHT, CONTROL_HEIGHT)];
}

// コントロールバーのフレーム更新
- (void) reloadControlBarFrame {
    // 広告バナーが表示されているかどうか
    float adheight = 0;
    if (!_adBannerView.hidden) {
        adheight = _adBannerView.frame.size.height;
    }
    
    //現在の向きを表すUIInterfaceOrientation取得
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    float leftmargin = 0;
    if ((orientation == UIInterfaceOrientationLandscapeLeft)
        || (orientation == UIInterfaceOrientationLandscapeRight)) {
        leftmargin = _screenSize.width / 2 + CONTROL_HEIGHT/ 2 + BAR_MARGIN * 2 + CONTROL_HEIGHT;
    } else {
        leftmargin =(_screenSize.width - _viewSpeed.frame.size.width - _viewSpeed.frame.origin.x) / 2 + _viewSpeed.frame.size.width + _viewSpeed.frame.origin.x + CONTROL_HEIGHT/ 2 + BAR_MARGIN * 2 + CONTROL_HEIGHT;
    }
    
    
    CGRect frame;
    
    // コントロールビュー
    frame = _viewControl.frame;
    frame.origin.y = _screenSize.height - CONTROL_HEIGHT - adheight;
    frame.size.width = _screenSize.width;
    _viewControl.frame = frame;
    CAGradientLayer *l = [_viewControl.layer.sublayers objectAtIndex:0];
    frame = l.frame;
    frame.size.width = _screenSize.width;
    l.frame = frame;
    // 停止ボタン
    frame = _btnStop.frame;
    frame.origin.x = leftmargin - CONTROL_HEIGHT;
    _btnStop.frame = frame;
    // 再生ボタン
    frame = _btnPlay.frame;
    frame.origin.x = _btnStop.frame.origin.x - BAR_MARGIN * 2 - CONTROL_HEIGHT;
    _btnPlay.frame = frame;
    // 巻き戻しボタン
    frame = _btnRewind.frame;
    frame.origin.x = _btnPlay.frame.origin.x - CONTROL_HEIGHT - BAR_MARGIN * 2;
    _btnRewind.frame = frame;
}

- (void) initControlViewWithFrame: (CGRect) frame {
    _viewControl = [[UIView alloc] initWithFrame:frame];
    
    // レイヤーの作成
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    // レイヤーサイズをビューのサイズをそろえる
    gradient.frame = _viewControl.bounds;
    
    // 開始色と終了色を設定
    gradient.colors = @[
                        // 開始色
                        (id)[UIColor colorWithRed:.18 green:.18 blue:.18 alpha:1].CGColor,
                        // 終了色
                        (id)[UIColor colorWithRed:.10 green:.10 blue:.10 alpha:1].CGColor
                        ];
    [_viewControl.layer insertSublayer:gradient atIndex:0];
    
    [self.view addSubview:_viewControl];
}

/// Speedビューの初期化
- (void) initSpeedViewWithFrame: (CGRect) frame Font: (UIFont *) font{
    // _stpSpeedの初期化
    _stpSpeed = [[UIStepper alloc] initWithFrame:CGRectMake(0, frame.size.height - 27, 94, 27)];
    _stpSpeed.value = 1;
    _stpSpeed.minimumValue = 0.5;
    _stpSpeed.maximumValue = 2;
    _stpSpeed.stepValue = 0.1;
    _stpSpeed.autorepeat = NO;
    _stpSpeed.tintColor = [UIColor lightGrayColor];
    [_stpSpeed addTarget:self action:@selector(changeSpeed:) forControlEvents:UIControlEventValueChanged];
    
    // _viewSpeedの幅はステッパーの幅にする
    frame.size.width = _stpSpeed.frame.size.width;
    
    // _viewSpeedの初期化
    _viewSpeed = [[UIView alloc] initWithFrame:frame];
    _viewSpeed.backgroundColor = [UIColor clearColor];
    [_viewControl addSubview:_viewSpeed];
    [_viewSpeed addSubview:_stpSpeed];
    
    // _lblSpeedの初期化
    _lblSpeed = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _viewSpeed.frame.size.width, _viewSpeed.frame.size.height - _stpSpeed.frame.size.height)];
    _lblSpeed.font = font;
    _lblSpeed.text = @"Speed  x1.0";
    _lblSpeed.textColor = [UIColor lightGrayColor];
    _lblSpeed.textAlignment = NSTextAlignmentCenter;
    [_viewSpeed addSubview:_lblSpeed];
    
}

/// 再生ボタンの初期化
- (void) initPlayButtonWithFrame: (CGRect) frame {
    _btnPlay = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnPlay.frame = frame;
    
    // バックイメージ
    [_btnPlay setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    // ターゲット
    [_btnPlay addTarget:self action:@selector(onPlayButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [_viewControl addSubview:_btnPlay];
}

/// 停止ボタンの初期化
- (void) initStopButtonWithFrame: (CGRect) frame {
    _btnStop = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnStop.frame = frame;
    
    // バックイメージ
    [_btnStop setBackgroundImage:[UIImage imageNamed:@"stop.png"] forState:UIControlStateNormal];
    [_btnStop setBackgroundImage:[UIImage imageNamed:@"stop-hilight.png"] forState:UIControlStateHighlighted];
    // ターゲット
    [_btnStop addTarget:self action:@selector(onStopButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [_viewControl addSubview:_btnStop];
}

/// 巻き戻しボタンの初期化
- (void) initRewindButtonWithFrame: (CGRect) frame {
    _btnRewind = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnRewind.frame = frame;
    
    // バックイメージ
    [_btnRewind setBackgroundImage:[UIImage imageNamed:@"rewind.png"] forState:UIControlStateNormal];
    // ターゲット
    [_btnRewind addTarget:self action:@selector(onRewindButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [_viewControl addSubview:_btnRewind];
}

#pragma mark - MusicPlayerView
/// プレイヤービューの初期化
- (void) initMusicPlayerView {
    // 曲名ラベルの初期化
    [self initSongLabelWithFrame:CGRectMake(PLAYER_MARGIN, _viewMenu.frame.origin.y +_viewMenu.frame.size.height + PLAYER_MARGIN, _screenSize.width - PLAYER_MARGIN * 2, PLAYER_COMPONENT_HEIGHT)];
    
    // 再生時間ラベルの初期化
    [self initTimeLabelWithFrame:CGRectMake(PLAYER_MARGIN, _viewControl.frame.origin.y -  PLAYER_COMPONENT_HEIGHT - PLAYER_MARGIN, _screenSize.width - PLAYER_MARGIN * 2, PLAYER_COMPONENT_HEIGHT)];
    
    // プレイヤービューの初期化
    _musicPlayerView = [[MusicPlayerView alloc] initWithFrame:CGRectMake(0, _lblSong.frame.origin.y + _lblSong.frame.size.height + PLAYER_MARGIN, _screenSize.width, _lblTime.frame.origin.y - (_lblSong.frame.origin.y + _lblSong.frame.size.height) - PLAYER_MARGIN * 2)];
    _musicPlayerView.delegate = self;
    _musicPlayerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_musicPlayerView];
    
    _musicPlayerView.hidden = YES;
}

/// プレイヤービューのフレーム更新
- (void) reloadMusicPlayerViewFrame {
    CGRect frame;
    
    // 曲名ラベル
    frame = _lblSong.frame;
    frame.origin.y = _viewMenu.frame.origin.y + _viewMenu.frame.size.height + PLAYER_MARGIN;
    frame.size.width = _screenSize.width - PLAYER_MARGIN * 2;
    _lblSong.frame = frame;
    // 再生時間ラベル
    frame = _lblTime.frame;
    frame.origin.y = _viewControl.frame.origin.y -  PLAYER_COMPONENT_HEIGHT - PLAYER_MARGIN;
    frame.size.width = _screenSize.width - PLAYER_MARGIN * 2;
    _lblTime.frame = frame;
    // プレイヤービュー
    frame = CGRectMake(0, _lblSong.frame.origin.y + _lblSong.frame.size.height + PLAYER_MARGIN, _screenSize.width, _lblTime.frame.origin.y - (_lblSong.frame.origin.y + _lblSong.frame.size.height) - PLAYER_MARGIN * 2);
    _musicPlayerView.frame = frame;
    [_musicPlayerView reloadViewFrame];
}

/// 曲名ラベルの初期化
- (void) initSongLabelWithFrame: (CGRect) frame {
    _lblSong = [[UILabel alloc] initWithFrame:frame];
    _lblSong.textColor = [UIColor whiteColor];
    _lblSong.textAlignment = NSTextAlignmentLeft;
    _lblSong.font = [UIFont systemFontOfSize:PLAYER_FONT_SIZE];
    [self.view addSubview:_lblSong];
}

/// 再生時間ラベルの初期化
- (void) initTimeLabelWithFrame: (CGRect) frame {
    _lblTime = [[UILabel alloc] initWithFrame:frame];
    _lblTime.textColor = [UIColor whiteColor];
    _lblTime.textAlignment = NSTextAlignmentCenter;
    _lblTime.font = [UIFont systemFontOfSize:PLAYER_FONT_SIZE];
    [self.view addSubview:_lblTime];
}

#pragma mark - AdBannerView
/// 広告バナーの初期化処理
- (void) initAdBanner {
    _adBannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    _adBannerView.delegate = self;
    _adBannerView.autoresizesSubviews = YES;
    _adBannerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _adBannerView.alpha = 0.0;
    CGRect frame;
    frame.size = CGSizeMake(_screenSize.width, _screenSize.height);
    _adBannerView.frame = frame;
    _adBannerView.frame = CGRectMake(0, _screenSize.height - _adBannerView.frame.size.height, _adBannerView.frame.size.width, _adBannerView.frame.size.height);
    [self.view addSubview:_adBannerView];
}

/// 広告バナーのフレーム更新
- (void) reloadAdBanner {
    CGRect frame;
    frame = _adBannerView.frame;
    frame.origin.y = _screenSize.height - _adBannerView.frame.size.height;
    _adBannerView.frame = frame;
}

#pragma mark - Show View

/// ローディング画面表示/非表示
- (void) showLoadView: (BOOL) show {
    if (_loadView == nil || _idcView == nil) {
        // ローディング画面生成
        _loadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenSize.width, _screenSize.height)];
        _loadView.alpha = 0.5;
        _loadView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:_loadView];
        _idcView = [[UIActivityIndicatorView alloc] init];
        _idcView.frame = CGRectMake(0, 0, 50, 50);
        _idcView.center = _loadView.center;
        _idcView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [_loadView addSubview:_idcView];
    }
    
    if (show) {
        _loadView.frame = CGRectMake(0, 0, _screenSize.width, _screenSize.height);
        _idcView.center = _loadView.center;
        _loadView.hidden = NO;
        [_idcView startAnimating];
    } else {
        _loadView.hidden = YES;
        [_idcView stopAnimating];
    }
}

/// 曲選択ビュー表示 MPMediaPickerControllerを表示
- (void) showMusicSelectView {
    // ステータスバーの色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    // MPMediaPickerControllerのインスタンスを作成
    MPMediaPickerController *picker = [[MPMediaPickerController alloc]init];
    // ピッカーのデリゲートを設定
    picker.delegate = self;
    // 複数選択を不可にする。（YESにすると、複数選択できる）
    picker.allowsPickingMultipleItems = NO;
    // ピッカーを表示する
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - Player
/// 再生
- (void) playerPlay {
    [_musicPlayer play];
//    [_btnPlay setTitle:@"Pause" forState:UIControlStateNormal];
    [_btnPlay setBackgroundImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
}

/// 一時停止
- (void) playerPause {
    [_musicPlayer pause];
//    [_btnPlay setTitle:@"Play" forState:UIControlStateNormal];
    [_btnPlay setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
}

/// 停止
- (void) playerStop {
    [_musicPlayer stop];
//    [_btnPlay setTitle:@"Play" forState:UIControlStateNormal];
    [_btnPlay setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    _musicPlayer.currentTime = _musicPlayerView.areaLoop.firstCursor.value;
}

/// 巻き戻し
- (void) playerRewind {
    _musicPlayer.currentTime = _musicPlayerView.areaLoop.firstCursor.value;
}

#pragma mark - Music Item
/// 音楽アイテムの更新
- (void) renewMusicItem: (MPMediaItem *) musicItem {
    /// 選択した音楽のURL
    NSURL *select = [_mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
    
    [self reset];
    
    
    // 選択した音楽をセット
    NSError* error = nil;
    _musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:select error:&error];
    if(!error) {
        // プレイヤーの設定
        _musicPlayer.enableRate = YES;
        _musicPlayer.rate = 1.0;
        _musicPlayer.numberOfLoops = -1;
        _stpSpeed.value = 1.0;
        [_musicPlayer prepareToPlay];
        
        // 曲情報取得
        _lblSong.text = [musicItem.title stringByAppendingFormat:@" / %@", musicItem.artist];
        
        // カーソル範囲設定
        [_musicPlayerView rangeValueWithMax:_mediaItem.playbackDuration Min:0.0];
        _musicPlayerView.areaLoop.firstCursor.value = _musicPlayerView.areaLoop.firstCursor.minimumValue;
        _musicPlayerView.areaLoop.lastCursor.value = _musicPlayerView.areaLoop.lastCursor.maximumValue;
        
        // 波形イメージ取得
        [_musicPlayerView loadWaveData:select];
        
        // 保存ボタン有効
        _btnSave.enabled = YES;
    } else {
        // 音楽ファイルを取り込むことができなかったら
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: nil
                                   message:NSLocalizedString(@"Couldn't Import Music File.", @"インポートできませんでした。")
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:@"OK", nil
         ];
        [alert show];
        [self showLoadView:NO];
    }
    
    
}

#pragma mark - Playing
/// 再生時間の取得
-(void) playingThread {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        while (YES) {
            dispatch_async(
                           dispatch_get_main_queue(),^{
                               [self reflectPlayingTime];
                               
                               [self reflectLoop];
                
                               [self reflectSilent];
                               
                               // 停止したら
                               if (!_musicPlayer.isPlaying) {
                                   [self playerPause];
                               }
                           });
            [NSThread sleepForTimeInterval:0.01];
        }
    });
}

/// 再生時間の反映
- (void) reflectPlayingTime {
    _musicPlayerView.csrPlay.value = _musicPlayer.currentTime;
    
    _lblTime.text =  [NSString stringWithFormat:@"%02d:%02d:%02d", (int)_musicPlayer.currentTime / 60, (int)_musicPlayer.currentTime % 60,(int)(((float)_musicPlayer.currentTime - (int)_musicPlayer.currentTime) * 100)];
}

/// ループの反映
- (void) reflectLoop {
    if (_musicPlayer.isPlaying && _musicPlayerView.csrPlay.value >= _musicPlayerView.areaLoop.lastCursor.value) {
        _musicPlayer.currentTime = _musicPlayerView.areaLoop.firstCursor.value;
    }
}

/// サイレントの反映
- (void) reflectSilent {
    static float oldVolume;
    
    if (_musicPlayer.volume != 0) {
        if (oldVolume != _musicPlayer.volume) {
            oldVolume = _musicPlayer.volume;
        }
    }
    if (!_isSilent && _musicPlayer.volume == 0) {
        _musicPlayer.volume = oldVolume;
    }
    if (_isSilent) {
        BOOL l = [_musicPlayerView inSilentRange];
        if (l) {
            _musicPlayer.volume = 0.0;
        } else {
            if (_musicPlayer.volume == 0) {
                _musicPlayer.volume = oldVolume;
            }

        }
    }
}


#pragma mark - Button
/// 新規ボタン処理
- (void) onNewButton: (UIButton *) button {
    [self showLoadView:YES];
    [self showMusicSelectView];
}

/// 保存ボタン処理
- (void) onSaveButton: (UIButton *) button {
    [self performSegueWithIdentifier:@"Save" sender:self];
}

/// Openボタン処理
- (void) onOpenButton: (UIButton *) button {
    [self performSegueWithIdentifier:@"Open" sender:self];
}

/// Shopボタン処理
- (void) onShopButton: (UIButton *) button {
    [self performSegueWithIdentifier:@"Shop" sender:self];
}

/// Silentボタン処理
- (void) onSilentButton: (UIButton *) button {
    [self setIsSilent: !_isSilent];
}

/// Helpボタン処理
- (void) onHelpButton: (UIButton *) button {
//    [self performSegueWithIdentifier:@"Info" sender:self];
    
    // Setup coach marks
    NSMutableArray *coachMarks = [NSMutableArray array];
    CGRect rect;
    
    // メニュー
    rect.origin.x = _viewMenu.frame.origin.x + _btnNew.frame.origin.x;
    rect.origin.y = _viewMenu.frame.origin.y + _btnNew.frame.origin.y;
    rect.size.width = _btnShop.frame.origin.x - _btnNew.frame.origin.x + _btnShop.frame.size.width;
    rect.size.height = _btnNew.frame.size.height;
    [coachMarks addObject:@{
                            @"rect": [NSValue valueWithCGRect:rect],
                            @"caption": NSLocalizedString(@"New : Open New file.\nSave : Save this file.\nOpen : Open a save file.\nShop : Go to the Shop page.", nil)
                            }];
    
    // Playerエリア
    if (!_musicPlayerView.hidden) {
        // ループカーソル
        rect.origin.x = _musicPlayerView.frame.origin.x;
        rect.origin.y = _musicPlayerView.frame.origin.y + _musicPlayerView.areaLoop.firstCursor.frame.origin.y;
        rect.size.width = _musicPlayerView.frame.size.width;
        rect.size.height = _musicPlayerView.areaLoop.firstCursor.frame.size.height;
        [coachMarks addObject:@{
                                @"rect": [NSValue valueWithCGRect:rect],
                                @"caption": NSLocalizedString(@"Loop Cursor Slider.\nDouble Tap to move to on the Play Cursor.", nil)
                                }];
        
        // 再生カーソル
        rect.origin.x = _musicPlayerView.frame.origin.x;
        rect.origin.y = _musicPlayerView.frame.origin.y + _musicPlayerView.csrPlay.frame.origin.y;
        rect.size.width = _musicPlayerView.frame.size.width;
        rect.size.height = _musicPlayerView.csrPlay.frame.size.height;
        [coachMarks addObject:@{
                                @"rect": [NSValue valueWithCGRect:rect],
                                @"caption": NSLocalizedString(@"Play Cursor Slider.", nil)
                                }];

        // サイレントカーソル
        if (_musicPlayerView.arraySilent.count != 0) {
            // カーソル
            CursorArea *s = [_musicPlayerView.arraySilent objectAtIndex:0];
            rect.origin.x = _musicPlayerView.frame.origin.x;
            rect.origin.y = _musicPlayerView.frame.origin.y + s.firstCursor.frame.origin.y;
            rect.size.width = _musicPlayerView.frame.size.width;
            rect.size.height = s.firstCursor.frame.size.height;
            [coachMarks addObject:@{
                                    @"rect": [NSValue valueWithCGRect:rect],
                                    @"caption": NSLocalizedString(@"Silent Cursor Slider.\nDouble Tap to move to on the Play Cursor.", nil)
                                    }];
            // エリア
            rect.origin.x = _musicPlayerView.frame.origin.x + _musicPlayerView.viewWaveImage.frame.origin.x + s.area.frame.origin.x;
            rect.origin.y = _musicPlayerView.frame.origin.y + _musicPlayerView.viewWaveImage.frame.origin.y + s.area.frame.origin.y;
            rect.size.width = s.area.frame.size.width;
            rect.size.height = s.area.frame.size.height;
            [coachMarks addObject:@{
                                    @"rect": [NSValue valueWithCGRect:rect],
                                    @"caption": NSLocalizedString(@"Silent Area Slider.\nLong Tap into here to show Delete button.", nil)
                                    }];
        } else {
            // 未表示時
            rect.origin.x = _musicPlayerView.frame.origin.x + _musicPlayerView.viewWaveImage.frame.origin.x;
            rect.origin.y = _musicPlayerView.frame.origin.y + _musicPlayerView.viewWaveImage.frame.origin.y;
            rect.size.width = _musicPlayerView.viewWaveImage.frame.size.width;
            rect.size.height = _musicPlayerView.viewWaveImage.frame.size.height;
            [coachMarks addObject:@{
                                    @"rect": [NSValue valueWithCGRect:rect],
                                    @"caption": NSLocalizedString(@"Wave Area.\nLong Tap into here to show a new Silent Area.", nil)
                                    }];
        }
    }
    
    // Silentボタン
    rect.origin.x = _viewMenu.frame.origin.x + _btnSilent.frame.origin.x;
    rect.origin.y = _viewMenu.frame.origin.y + _btnSilent.frame.origin.y;
    rect.size = _btnSilent.frame.size;
    [coachMarks addObject:@{
                            @"rect": [NSValue valueWithCGRect:rect],
                            @"caption": NSLocalizedString(@"Silent On/Off.\nWhen turned On, Sound is silence between the Silent Areas.", nil)
                            }];

    // スピード
    rect.origin.x = _viewControl.frame.origin.x + _viewSpeed.frame.origin.x;
    rect.origin.y = _viewControl.frame.origin.y + _viewSpeed.frame.origin.y;
    rect.size = _viewSpeed.frame.size;
    [coachMarks addObject:@{
                            @"rect": [NSValue valueWithCGRect:rect],
                            @"caption": NSLocalizedString(@"Change Playing Speed.\nYou need to buy to use this at the Shop page.", nil)
                            }];
    
    // コントロール
    rect.origin.x = _viewControl.frame.origin.x + _btnRewind.frame.origin.x;
    rect.origin.y = _viewControl.frame.origin.y + _btnRewind.frame.origin.y;
    rect.size.width = _btnStop.frame.origin.x - _btnRewind.frame.origin.x + _btnStop.frame.size.width;
    [coachMarks addObject:@{
                            @"rect": [NSValue valueWithCGRect:rect],
                            @"caption": NSLocalizedString(@"Control Playing.", nil)
                            }];
    
    _viewCoachMarks = [[WSCoachMarksView alloc] initWithFrame:CGRectMake(0, 0, _screenSize.width, _screenSize.height)];
    [self.view addSubview:_viewCoachMarks];
    _viewCoachMarks.coachMarks = coachMarks;
    [_viewCoachMarks start];
}

/// 再生/一時停止ボタン処理
- (void)onPlayButton:(UIButton *)button {
    if (_musicPlayer.playing) {
        [self playerPause];
    } else {
        [self playerPlay];
    }
}

/// 停止ボタン処理
- (void)onStopButton:(UIButton *)button {
    [self playerStop];
}

/// 巻き戻しボタン処理
- (void) onRewindButton: (UIButton *) button {
    [self playerRewind];
}

/// 再生スピードの変更
- (void)changeSpeed:(UIStepper *)stepper {
    _musicPlayer.rate = _stpSpeed.value;
    _lblSpeed.text = [NSString stringWithFormat:@"Speed  x%.1f", _musicPlayer.rate];
}

#pragma mark - MPMediaPickerControllerDelegate
// メディアアイテムピッカーでアイテムを選択完了したときに呼び出される
- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    
    _mediaItem = [mediaItemCollection.items objectAtIndex:0];
    
    [self renewMusicItem:_mediaItem];
    
    // ピッカーを閉じ、破棄する
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}

//選択がキャンセルされた場合に呼ばれる
- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker{
        // ピッカーを閉じ、破棄する
        [mediaPicker dismissViewControllerAnimated:YES completion:nil];
        
        [self showLoadView:NO];
}

#pragma mark - MusicPlayerViewDelegate
/// 再生時間変更通知
- (void) changePlayTime:(float) time {
    _musicPlayer.currentTime = time;
//    _lblTime.text =  [NSString stringWithFormat:@"%.1f", time];
    _lblTime.text =  [NSString stringWithFormat:@"%02d:%02d:%02d", (int)time / 60, (int)time % 60,(int)(((float)time - (int)_musicPlayer.currentTime) * 100)];
}

/// 音楽ファイルのロード開始通知
- (void) startLoadingMusic {
    [self showLoadView:YES];
}

/// 音楽ファイルのロード完了通知
- (void) completedLoadingMusic {
    // 停止
    [self onStopButton:nil];
    // 再生
    //    [self playerPlay];
    // シーク開始
    [self playingThread];
    
    [self showLoadView:NO];
    
    _musicPlayerView.hidden = NO;
}

/// エラー通知
- (void) errorMusicPlayerView:(MusicPlayerViewError)error {
    NSString *msg;
    
    switch (error) {
        case MusicPlayerViewFailedLoadWaveImage:
            msg = NSLocalizedString(@"Coudn't Load Wave Image.", nil) ;
            break;
        case MusicPlayerViewSilentFull:
            msg = NSLocalizedString(@"Silent Area is Full. Please buy the Product to add Silent Area more from Shop!", nil) ;
            break;
        default:
            break;
    }
    
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle: nil
                               message:msg
                              delegate:nil
                     cancelButtonTitle:nil
                     otherButtonTitles:@"OK", nil
     ];
    [alert show];

}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"Save"] ) {
        SaveViewController *svc = (SaveViewController*)[segue destinationViewController];
        svc.mediaItem = _mediaItem;
        svc.arraySilent = _musicPlayerView.arraySilent;
        svc.loopArea = _musicPlayerView.areaLoop;
        svc.delegate = self;
    } else if ( [segue.identifier isEqualToString:@"Open"]) {
        SaveViewController *svc = (SaveViewController*)[segue destinationViewController];
        svc.mediaItem = nil;
        svc.arraySilent = nil;
        svc.loopArea = nil;
        svc.delegate = self;
    }
}

#pragma mark - SaveViewDelegate
- (void) finishView:(NSDictionary *)returnData {
    // 音楽アイテムの更新
    _mediaItem = [NSKeyedUnarchiver unarchiveObjectWithData:[returnData objectForKey:kMediaKey]];
    
    [self renewMusicItem:_mediaItem];
    
    // サイレント区間の更新
    NSMutableArray *silentData = [returnData objectForKey:kSilentKey];
    for (NSDictionary *d in silentData) {
        [_musicPlayerView addSilentAreaWithFirstValue:[(NSNumber *)[d objectForKey:kFirstKey] floatValue] LastValue:[(NSNumber *)[d objectForKey:kLastKey] floatValue]];
    }
    
    // ループ区間の更新
    NSDictionary *loopData = [returnData objectForKey:kLoopKey];
    _musicPlayerView.areaLoop.firstValue = [(NSNumber *)[loopData objectForKey:kFirstKey] floatValue];
    _musicPlayerView.areaLoop.lastValue = [(NSNumber *)[loopData objectForKey:kLastKey] floatValue];
}

#pragma mark - ADBannerViewDelegate
- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    if (!_bannerVisible) {
        [UIView animateWithDuration:0.3f animations:^{
            banner.alpha = 1.0f;
        }];
        _bannerVisible = YES;
    }
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    if (_bannerVisible) {
        [UIView animateWithDuration:0.3f animations:^{
            banner.alpha = 0.0f;
        }];
        _bannerVisible = NO;
    }
}

@end