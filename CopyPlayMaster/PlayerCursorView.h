//
//  PlayerCursorView.h
//  MediaPlayerTestSample
//
//  Created by user on 2015/02/26.
//  Copyright (c) 2015年 yamasaki. All rights reserved.
//

#import "CursorView.h"
#import "CursorSize.h"

/// 音楽プレイヤー用カーソル
@interface PlayerCursorView : CursorView {
    /// サム
    UIView *_thum;
}

- (id) initWithSuperView: (UIView *) superview WaveView: (UIView *) waveview;
/// フレーム更新
- (void) reloadViewFrameWithWaveFrame: (CGRect) waveframe;

@end
