//
//  StoreViewController.h
//  MediaPlayerTestSample
//
//  Created by user on 2015/03/25.
//  Copyright (c) 2015年 yamasaki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaymentManager.h"
#import "ProductManager.h"

#define MENU_HEIGHT 35
#define BAR_MARGIN 4
#define MENU_COMPONENT_WIDTH 45
#define MENU_FONT_SIZE 10

@interface StoreViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, PaymentManagerDelegate>{
    /// テーブルビュー
    IBOutlet UITableView *_tableProduct;
    
    /// メニュービュー
    UIView *_viewMenu;
    /// backボタン
    UIButton *_btnBack;
    /// restoreボタン
    UIButton *_btnRestore;
    
    /// サイレントエリア数
    IBOutlet UILabel *_lblSilentArea;
    IBOutlet UILabel *_lblSaveSlot;
    
    /// スクリーンサイズ
    CGSize _screenSize;
    
    /// アプリ内課金マネージャー
    PaymentManager *_paymentManager;
    
    /// アラートビュー
    UIAlertView *_alertView;
    
    /// 購入可能なプロダクト一覧
    NSArray *_products;
    
    /// プロダクト管理クラス
    ProductManager *_productManager;
}

@end
