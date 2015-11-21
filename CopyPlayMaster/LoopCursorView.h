//
//  SilentCursorView.h
//  CopyTrainingPlayer
//
//  Created by user on 2015/03/31.
//  Copyright (c) 2015年 yamasaki. All rights reserved.
//

#import "CursorView.h"
#import "CursorSize.h"

/// ループエリア用カーソル
@interface LoopCursorView : CursorView {
    /// サム
    UIView *_thum;
}

- (id) initWithSuperView: (UIView *) superview WaveView: (UIView *) waveview Color: (UIColor *) color;
/// フレーム更新
- (void) reloadViewFrameWithWaveFrame: (CGRect) waveframe;

@end
