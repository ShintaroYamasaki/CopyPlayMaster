//
//  LoopArea.h
//  MediaPlayerTestSample
//
//  Created by user on 2015/02/24.
//  Copyright (c) 2015年 yamasaki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CursorView.h"
#import "LoopCursorView.h"
#import "SilentCursorView.h"

typedef enum {
    CursorAreaLoop,
    CursorAreaSilent
}CursorAreaMode;

/// カーソル範囲
@interface CursorArea : NSObject<CursorViewDelegate> {
    /// 間隔限界
    float _maxdif;
}

/// 始点カーソル
@property(nonatomic) CursorView *firstCursor;
/// 終点カーソル
@property(nonatomic) CursorView *lastCursor;
/// 範囲ビュー
@property(nonatomic) CursorView *area;
/// モード
@property(nonatomic, readonly) CursorAreaMode mode;
/// カーソルの色
@property(nonatomic, readonly) UIColor *color;
/// 始点の位置
@property (nonatomic) float firstPoint;
/// 終点の位置
@property (nonatomic) float lastPoint;
/// 範囲の中心位置
@property (nonatomic) float centerPoint;
/// 始点の値
@property (nonatomic) float firstValue;
/// 終点の値
@property (nonatomic) float lastValue;
/// 範囲の中心値
@property (nonatomic) float centerValue;


- (id) initWithSuperView: (UIView *) superview WaveView: (UIView *) waveview Mode:(CursorAreaMode) mode;
/// 値の範囲指定
- (void) rangeValueWithMax: (float) maximum Min: (float) minimum;
/// ビューのフレーム更新
- (void) reloadViewFrameWithWaveFrame:(CGRect) waveframe;

@end
