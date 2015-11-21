//
//  SaveViewController.m
//  MediaPlayerTestSample
//
//  Created by user on 2015/02/24.
//  Copyright (c) 2015年 yamasaki. All rights reserved.
//

#import "SaveViewController.h"

@interface SaveViewController ()

@end

@implementation SaveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getScreenSize:[UIApplication sharedApplication].statusBarOrientation];
    
    [self initMenuBar];
    
    // テーブルビュー
    _tableSaved = [[UITableView alloc] initWithFrame:CGRectMake(0, _viewMenu.frame.origin.y + _viewMenu.frame.size.height, _screenSize.width, _screenSize.height - _viewMenu.frame.size.height) style:UITableViewStylePlain];
    _tableSaved.delegate = self;
    _tableSaved.dataSource = self;
    [self.view addSubview:_tableSaved];
    
    // Openの場合、保存ボタンを表示させない
    if (_mediaItem == nil) {
        _btnSave.hidden = YES;
    }
    
    // 保存データ取得
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    _saveData = [(NSMutableArray *)[ud arrayForKey:kSaveKey] mutableCopy];
    if (_saveData == nil) {
        _saveData = [NSMutableArray new];
    }

    // プロダクトマネージャー
    _productManager = [ProductManager sharedInstance];
    
    [_tableSaved reloadData];
    
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
    _viewMenu.userInteractionEnabled = YES;
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
    _btnBack.enabled = YES;
    
    [_viewMenu addSubview:_btnBack];
    
    
    // saveボタン
    _btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnSave.frame = CGRectMake(_viewMenu.frame.size.width - BAR_MARGIN * 3 - btnsize.width, BAR_MARGIN, btnsize.width, btnsize.height);
    // テキスト
    [_btnSave setTitle:@"Save" forState:UIControlStateNormal];
    [_btnSave.titleLabel setFont:font];
    [_btnSave setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    // バックイメージ
    [_btnSave setBackgroundImage:[UIImage imageNamed:@"frame-blue.png"] forState:UIControlStateNormal];
    // ターゲット
    [_btnSave addTarget:self action:@selector(onSaveButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [_viewMenu addSubview:_btnSave];

}

- (void) reloadMenuBar {
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
    // saveボタン
    frame = _btnSave.frame;
    frame.origin.x = _viewMenu.frame.size.width - BAR_MARGIN * 3 - btnsize.width;
    _btnSave.frame = frame;
    
    // table
    frame = _tableSaved.frame;
    frame.origin.y = _viewMenu.frame.size.height + _viewMenu.frame.origin.y;
    frame.size.width = _screenSize.width;
    frame.size.height = _screenSize.height - _viewMenu.frame.size.height;
    _tableSaved.frame = frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/// 戻るボタン
- (void)onBackButton:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}


/// 保存ボタン
- (void)onSaveButton:(UIButton *)button {
//      // 全削除
//    NSUserDefaults *uds = [NSUserDefaults standardUserDefaults];
//    [uds removeObjectForKey:kSaveKey];
    
    int index;
    
    for (index = 0; index < _saveData.count; index++) {
        NSDictionary *d = [_saveData objectAtIndex:index];
        MPMediaItem *mi = [NSKeyedUnarchiver unarchiveObjectWithData: [d objectForKey:kMediaKey]];
        if ([mi.title isEqualToString: _mediaItem.title] && [mi.artist isEqualToString:_mediaItem.artist]) {
            break;
        }
    }
    if (index == _saveData.count) {
        if (_saveData.count == _productManager.saveSlot) {
            UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Save Slot", nil)
                                       message: NSLocalizedString(@"Save Slot is Full. Please delete the other Save Data or buy this Product from Shop!", nil)
                                      delegate:nil
                             cancelButtonTitle:nil
                             otherButtonTitles:@"OK", nil
             ];
            [alert show];
            return;
        }
    }
    
    
    
    // 音楽データをアーカイブ
    NSData *mediaData = [NSKeyedArchiver archivedDataWithRootObject:_mediaItem];
    
    // 無音区間の始点と終点を格納
    NSMutableArray *silentData = [NSMutableArray new];
    for (CursorArea *s in _arraySilent) {
        NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithFloat:s.firstCursor.value], kFirstKey,
                           [NSNumber numberWithFloat:s.lastCursor.value], kLastKey,
                           nil];
        [silentData addObject:d];
    }
    
    // ループ区間の始点と終点を格納
    NSDictionary *loopData = [NSDictionary dictionaryWithObjectsAndKeys:
                       [NSNumber numberWithFloat:_loopArea.firstCursor.value], kFirstKey,
                       [NSNumber numberWithFloat:_loopArea.lastCursor.value], kLastKey,
                       nil];
    
    // 保存データをまとめる
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                   mediaData, kMediaKey,
                   silentData, kSilentKey,
                   loopData, kLoopKey,
                   nil];
    
    
    if (index == _saveData.count) {
        // 新規
        [_saveData addObject:data];
    } else {
        // 上書き処理
        [_saveData replaceObjectAtIndex:index withObject:data];

    }
    
    // 保存
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:(NSArray *)_saveData forKey:kSaveKey];
    [ud synchronize];
    
    // 保存しましたアラート
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Save", nil)
                               message: NSLocalizedString(@"Completed", nil)
                              delegate:nil
                     cancelButtonTitle:nil
                     otherButtonTitles:@"OK", nil
     ];
    [alert show];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    switch(section) {
//        case 0:
//            return @"Load";
//            break;
//    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _saveData.count;
};

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    // 再利用できるセルがあれば再利用する
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        // 再利用できない場合は新規で作成
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *data = [_saveData objectAtIndex:indexPath.row];
    MPMediaItem *mi = [NSKeyedUnarchiver unarchiveObjectWithData: [data objectForKey:kMediaKey]];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ / %@", mi.title, mi.artist];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [_saveData removeObjectAtIndex:indexPath.row];
        
        // 更新
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:(NSArray *)_saveData forKey:kSaveKey];
        [ud synchronize];

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Saveの場合、開かない
    if (_mediaItem != nil) {
        return;
    }
    
    NSDictionary *d = [_saveData objectAtIndex:indexPath.row];
    
    // ローディング画面
    CGRect screen = [[UIScreen mainScreen] bounds];
    UIView *loadView = [[UIView alloc] initWithFrame:screen];
    loadView.alpha = 0.5;
    loadView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:loadView];
    UIActivityIndicatorView *idcView = [[UIActivityIndicatorView alloc] init];
    idcView.frame = CGRectMake(0, 0, 50, 50);
    idcView.center = self.view.center;
    idcView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [loadView addSubview:idcView];
    [idcView startAnimating];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([_delegate respondsToSelector:@selector(finishView:)]){
        [_delegate finishView:d];
    }

}

@end
