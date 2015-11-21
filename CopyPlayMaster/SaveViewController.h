//
//  SaveViewController.h
//  MediaPlayerTestSample
//
//  Created by user on 2015/02/24.
//  Copyright (c) 2015年 yamasaki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "CursorArea.h"
#import "ProductManager.h"

#define kSaveKey @"SAVE"
#define kMediaKey @"MEDIA"
#define kSilentKey @"SILENT"
#define kLoopKey @"LOOP"
#define kFirstKey @"First"
#define kLastKey @"Last"

#define MENU_HEIGHT 35
#define BAR_MARGIN 4
#define MENU_COMPONENT_WIDTH 45
#define MENU_FONT_SIZE 10

// 保存画面デリゲート
@protocol SaveViewDelegate <NSObject>

/// 値渡し用メソッド
- (void) finishView: (NSDictionary *) returnData;

@end

/// 保存画面コントローラ
@interface SaveViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    /// 保存データ
    NSMutableArray *_saveData;
    
    // スクリーンサイズ
    CGSize _screenSize;
    
    /// メニュービュー
    UIView *_viewMenu;
    /// backボタン
    UIButton *_btnBack;
    /// 保存ボタン
    UIButton *_btnSave;
    
    IBOutlet UIView *_viewforMenu;

    
    /// 保存データ表示用デーブルビュー
    UITableView *_tableSaved;
    
    
    /// プロダクトマネージャー
    ProductManager *_productManager;
}
/// 音楽データ
@property(nonatomic) MPMediaItem *mediaItem;
/// サイレント区間
@property (nonatomic) NSMutableArray *arraySilent;
/// ループ区間
@property (nonatomic) CursorArea *loopArea;
/// デリゲート
@property (nonatomic) id<SaveViewDelegate> delegate;

@end
