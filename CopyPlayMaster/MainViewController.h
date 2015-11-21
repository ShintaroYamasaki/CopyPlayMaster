//
//  ViewController.h
//  MediaPlayerTestSample
//
//  Created by user on 2014/12/19.
//  Copyright (c) 2014年 yamasaki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <iAd/iAd.h>

#import "SaveViewController.h"
#import "StoreViewController.h"
#import "WaveformImageVew.h"
#import "PlayerCursorView.h"
#import "CursorArea.h"
#import "ProductManager.h"
#import "WSCoachMarksView.h"
#import "MusicPlayerView.h"

#define MENU_HEIGHT 35
#define CONTROL_HEIGHT 50
#define BAR_MARGIN 4
#define PLAYER_MARGIN 8
#define PLAYER_COMPONENT_HEIGHT 15
#define MENU_COMPONENT_WIDTH 45
#define MENU_FONT_SIZE 10
#define PLAYER_FONT_SIZE 12
#define BTNSILENT_WIDTH 60


typedef enum {
    ModeNone,
    ModeNew,
    ModeLoad
} MODE;

@interface MainViewController : UIViewController<MusicPlayerViewDelegate, MPMediaPickerControllerDelegate, SaveViewDelegate, ADBannerViewDelegate> {
    
    /// プレイヤー
    AVAudioPlayer *_musicPlayer;
    /// 選択した音楽データ
    MPMediaItem *_mediaItem;
    
    /// プレイヤービュー
    MusicPlayerView *_musicPlayerView;
    
    /// メニュービュー
    UIView *_viewMenu;
    /// Newボタン
    UIButton *_btnNew;
    /// Openボタン
    UIButton *_btnOpen;
    /// Saveボタン
    UIButton *_btnSave;
    /// Shopボタン
    UIButton *_btnShop;
    /// サイレントボタン
    UIButton *_btnSilent;
    /// ヘルプボタン
    UIButton *_btnHelp;
    
    /// コントロールビュー
    UIView *_viewControl;
    /// Speedビュー
    UIView *_viewSpeed;
    /// 再生速度ラベル
    UILabel *_lblSpeed;
    /// 再生速度ステッパー
    UIStepper *_stpSpeed;
    /// 再生/一時停止ボタン
    IBOutlet UIButton *_btnPlay;
    /// 停止ボタン
    UIButton *_btnStop;
    /// 巻き戻しボタン
    UIButton *_btnRewind;
    
    /// 曲名ラベル
    IBOutlet UILabel *_lblSong;
    /// 再生時間
    IBOutlet UILabel *_lblTime;
    
    
    // スクリーンサイズ
    CGSize _screenSize;
    
    
    
    /// ローディングビュー
    UIView *_loadView;
    /// インジケータ
    UIActivityIndicatorView *_idcView;
    
    /// iAdバナー
    ADBannerView *_adBannerView;
    /// iAdバナーの表示/非表示
    BOOL _bannerVisible;
    
    /// プロダクトマネージャー
    ProductManager *_productManager;
    
    /// 使い方説明
    WSCoachMarksView *_viewCoachMarks;

}
/// 表示時のモード
@property(nonatomic) MODE mode;
/// サイレントフラグ
@property (nonatomic) BOOL isSilent;

@end
