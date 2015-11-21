//
//  StoreViewController.m
//  MediaPlayerTestSample
//
//  Created by user on 2015/03/25.
//  Copyright (c) 2015年 yamasaki. All rights reserved.
//

#import "StoreViewController.h"

@interface StoreViewController ()

@end

@implementation StoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getScreenSize:[UIApplication sharedApplication].statusBarOrientation];
    
    [self initMenuBar];
    
    // テーブルビュー
    _tableProduct = [[UITableView alloc] initWithFrame:CGRectMake(0, _viewMenu.frame.origin.y + _viewMenu.frame.size.height, _screenSize.width, _screenSize.height - _viewMenu.frame.size.height) style:UITableViewStylePlain];
    _tableProduct.delegate = self;
    _tableProduct.dataSource = self;
    [self.view addSubview:_tableProduct];
    
    // プロダクト管理クラスの設定
    _productManager = [ProductManager sharedInstance];
    
    // アプリ内課金マネージャーの設定
    _paymentManager = [PaymentManager sharedInstance];  // 複数のクラスで単一のインスタンスを扱うことをできるようにsharedInstanceで初期化
    _paymentManager.delegate = self;                    // PaymentManagerDelegateを設定
    
    // テーブルビューの設定
    _tableProduct.delegate = self;
    _tableProduct.dataSource = self;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // プロダクト情報の取得
    [_paymentManager requestProductInfo:_productManager.productIds];
    [self setAlertViewWithTitle:NSLocalizedString(@"Processing", nil)  Message:NSLocalizedString(@"Getting Product Information", nil) CancelButtonTitle:nil];
    [_alertView show];
    
    [self showSlotAndAreaNum];
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
    

    // Restoreボタン
    _btnRestore = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnRestore.frame = CGRectMake(_viewMenu.frame.size.width - BAR_MARGIN * 3 - btnsize.width, BAR_MARGIN, btnsize.width, btnsize.height);
    // テキスト
    [_btnRestore setTitle:@"Restore" forState:UIControlStateNormal];
    [_btnRestore.titleLabel setFont:font];
    [_btnRestore setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    // バックイメージ
    [_btnRestore setBackgroundImage:[UIImage imageNamed:@"frame-blue.png"] forState:UIControlStateNormal];
    // ターゲット
    [_btnRestore addTarget:self action:@selector(onRestoreButton:) forControlEvents:UIControlEventTouchUpInside];
    [_viewMenu addSubview:_btnRestore];
    
    // ラベル
    _lblSaveSlot = [[UILabel alloc] initWithFrame:CGRectMake(_btnBack.frame.origin.x + _btnBack.frame.size.width +  BAR_MARGIN, BAR_MARGIN, _viewMenu.frame.size.width - BAR_MARGIN * 3 - btnsize.width * 2, btnsize.height / 2)];
    [_lblSaveSlot setFont:font];
    [_lblSaveSlot setTextColor:[UIColor lightGrayColor]];
    [_viewMenu addSubview:_lblSaveSlot];
    _lblSilentArea = [[UILabel alloc] initWithFrame:CGRectMake(_btnBack.frame.origin.x + _btnBack.frame.size.width +  BAR_MARGIN, btnsize.height / 2, _viewMenu.frame.size.width - BAR_MARGIN * 3 - btnsize.width * 2, btnsize.height / 2)];
    [_lblSilentArea setFont:font];
    [_lblSilentArea setTextColor:[UIColor lightGrayColor]];
    [_viewMenu addSubview:_lblSilentArea];
    
    [self showSlotAndAreaNum];
    
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
    // restoreボタン
    frame = _btnRestore.frame;
    frame.origin.x = _screenSize.width - BAR_MARGIN * 3 - btnsize.width;
    _btnRestore.frame = frame;
    
    // table
    frame = _tableProduct.frame;
    frame.origin.y = _viewMenu.frame.size.height + _viewMenu.frame.origin.y;
    frame.size.width = _screenSize.width;
    frame.size.height = _screenSize.height - _viewMenu.frame.size.height;
    _tableProduct.frame = frame;
}


/// 保存スロット・サイレントエリア数の表示
- (void) showSlotAndAreaNum {
    _lblSaveSlot.text = [NSLocalizedString(@"Save Slot", nil)  stringByAppendingFormat:@" : %ld", (long)_productManager.saveSlot];
    _lblSilentArea.text = [NSLocalizedString(@"Silent Area", nil) stringByAppendingFormat:@" : %ld", (long)_productManager.silentArea];
}

/// リストアボタン処理
- (void)onRestoreButton:(UIButton *)button {
    if ([_paymentManager startRestore]) {
        [self setAlertViewWithTitle:NSLocalizedString(@"Processing", nil)  Message:NSLocalizedString(@"Restore", nil) CancelButtonTitle:nil];
        [_alertView show];
    };
}

- (void)onBackButton:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/// アラートのパラメータ設定
- (void) setAlertViewWithTitle: (NSString *) title Message: (NSString *) message CancelButtonTitle: (NSString *) cancel {
    [_alertView dismissWithClickedButtonIndex:0 animated:YES];

    _alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancel otherButtonTitles:nil];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - PaymentManagerDelegate
- (void) completePayment:(SKPaymentTransaction *)transaction {
    // 購入状況の更新
    [_productManager bought:transaction.payment.productIdentifier];
    
    [self showSlotAndAreaNum];

}

- (void) responseProductInfo:(NSArray *)products InvalidProducts:(NSArray *)invalidProducts {
    _products = products;
    // テーブルビューに表示
    [_tableProduct reloadData];
}

- (void) onPaymentStatus:(PaymentStatus)status {
    
    [_alertView dismissWithClickedButtonIndex:0 animated:YES];
    _alertView = nil;
    
    NSString *statusText;
    
    switch (status) {
        case PaymentStatusPurchasing:
            statusText = NSLocalizedString(@"PaymentStatusPurchasing", nil);
            break;
        case PaymentStatusPurchased:
            statusText = NSLocalizedString(@"PaymentStatusPurchased", nil);
            break;
        case PaymentStatusRestored:
            statusText = NSLocalizedString(@"PaymentStatusRestored", nil);
            [self setAlertViewWithTitle:nil Message:NSLocalizedString(@"Restored", nil) CancelButtonTitle:@"OK"];
            [_alertView show];
            break;
        case PaymentStatusResponsedProductInfo:
            statusText = NSLocalizedString(@"PaymentStatusResponsedProductInfo", nil);
            break;
        case PaymentStatusFailed:
            statusText = NSLocalizedString(@"PaymentStatusFailed", nil);
            break;
        default:
            break;
    }
    
    NSLog(@"%@", statusText);
    
}

- (void) onPaymentError:(PaymentError)error {
    NSString *errorText;
    
    switch (error) {
        case PaymentErrorNotAllowed:
            errorText = NSLocalizedString(@"Not Allowed Payment", nil);
            break;
        case PaymentErrorCancelled:
            errorText = NSLocalizedString(@"Cancelled", nil);
            break;
        case PaymentErrorClientInvalid:
            errorText = NSLocalizedString(@"Client Invalid", nil);
            break;
        case PaymentErrorInvalid:
            errorText = NSLocalizedString(@"Invalied", nil);
            break;
        case PaymentErrorResponsedProductInfo:
            errorText = NSLocalizedString(@"Response Error", nil);
            break;
        case PaymentErrorUnknown:
            errorText = NSLocalizedString(@"Error", nil);
            break;
        case PaymentErrorFailedRestore:
            errorText = NSLocalizedString(@"Failed Restore", nil);
            break;
        default:
            break;
    }
    
    NSLog(@"%@", errorText);
    
    [self setAlertViewWithTitle:nil Message:errorText CancelButtonTitle:@"OK"];
    [_alertView show];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_products count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if ( nil == cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:identifier];
    }
    
    SKProduct *product = [_products objectAtIndex:indexPath.row];
    cell.textLabel.text = product.localizedTitle;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", product.price];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 保持していたプロダクトのリストから該当のプロダクトを取り出す
    SKProduct *product = [_products objectAtIndex:indexPath.row];
    
    // 購入処理中にUIAlertViewを表示させる
    [self setAlertViewWithTitle: NSLocalizedString(@"Processing", nil) Message:[NSString stringWithFormat:@"%@", product.localizedTitle] CancelButtonTitle:nil];
    [_alertView show];
    
    // プロダクトの購入処理を開始させる
    [_paymentManager buyProduct:product];
    
}

@end
