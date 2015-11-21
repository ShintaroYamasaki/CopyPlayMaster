//
//  MusicPlayerView.h
//  CopyTrainingPlayer
//
//  Created by user on 2015/03/26.
//  Copyright (c) 2015年 yamasaki. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WaveformImageVew.h"
#import "CursorArea.h"
#import "PlayerCursorView.h"
#import "ProductManager.h"

typedef enum {
    /// サイレントエリアが上限を越えようとしている
    MusicPlayerViewSilentFull,
    /// 波形イメージの取り込みに失敗
    MusicPlayerViewFailedLoadWaveImage
}MusicPlayerViewError;

@protocol MusicPlayerViewDelegate <NSObject>

/// 再生時間変更通知
- (void) changePlayTime: (float) time;

/// 音楽ファイルのロード開始通知
- (void) startLoadingMusic;

/// 音楽ファイルのロード完了通知
- (void) completedLoadingMusic;

/// エラー通知
- (void) errorMusicPlayerView: (MusicPlayerViewError) error;

@end

@interface MusicPlayerView : UIView<WaveformImageViewDelegate, CursorViewDelegate> {
    // サイレントエリア格納
    NSMutableArray *_arraySilent;
    
    /// 選択されたサイレントエリア
    int _selectSilent;
    /// サイレントエリア削除ボタン
    UIButton *_btnDltSilent;
    /// サイレントエリア削除キャンセルボタン
    UIButton *_btnCxlSilent;
    
    /// プロダクトマネージャー
    ProductManager *_productManager;

    /// カーソルの最大値
    float _csrMaximumValue;
    /// カーソルの最小値
    float _csrMinimumValue;
}

// サイレントエリア格納
@property (nonatomic) NSMutableArray *arraySilent;
/// 波形イメージビュー
@property (nonatomic) WaveformImageVew *viewWaveImage;
/// 再生カーソルビュー
@property (nonatomic) PlayerCursorView *csrPlay;
/// ループエリア
@property (nonatomic) CursorArea *areaLoop;
/// サイレントエリア
@property (nonatomic) CursorArea *areaSilent;
/// デリゲート
@property (nonatomic) id<MusicPlayerViewDelegate> delegate;

/// 値の範囲設定
- (void) rangeValueWithMax: (float) maximum Min:(float)minimum;
/// 波形データの表示
- (void) loadWaveData: (NSURL *) url;
/// サイレントエリアの初期化・追加処理(座標)
- (CursorArea *) addSilentAreaWithFirstPoint: (float) first LastPoint: (float) last;
///　サイレントエリアの初期化・追加処理(値)
- (CursorArea *) addSilentAreaWithFirstValue: (float) first LastValue: (float) last;
/// サイレントエリア全削除
- (void) removeAllSilentArea;
/// サイレントエリア内かどうか判定
- (BOOL) inSilentRange;
/// ビューのフレーム更新
- (void) reloadViewFrame;


@end
