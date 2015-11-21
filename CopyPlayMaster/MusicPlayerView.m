//
//  MusicPlayerView.m
//  CopyTrainingPlayer
//
//  Created by user on 2015/03/26.
//  Copyright (c) 2015年 yamasaki. All rights reserved.
//

#import "MusicPlayerView.h"

@implementation MusicPlayerView

- (id) initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self initWaveImageView];
        [self initPlayCursor];
        [self initLoopArea];
        
        _arraySilent = [NSMutableArray new];
        
        // プロダクトマネージャー
        _productManager = [ProductManager sharedInstance];
        
    }
    
    return self;
}

/// 値の範囲設定
- (void) rangeValueWithMax: (float) maximum Min:(float)minimum {
    // 再生カーソル設定
    _csrPlay.minimumValue = minimum;
    _csrPlay.maximumValue = maximum;
    _csrPlay.value = 0.0;
    
    // ループ範囲バー設定
    [_areaLoop rangeValueWithMax:maximum Min:minimum];
    
    // サイレントエリア設定
    for (CursorArea *s in _arraySilent) {
        [s rangeValueWithMax:maximum Min:minimum];
    }
    
    _csrMaximumValue = maximum;
    _csrMinimumValue = minimum;
}

/// ビューのフレーム更新
- (void) reloadViewFrame {
    CGRect frame;
    
    // 波形ビュー
    frame = _viewWaveImage.frame;
    frame.size.width = self.frame.size.width - 32;
    frame.size.height = self.frame.size.height - WAVE_MARGIN * 3;
    _viewWaveImage.frame = frame;
    
    // 再生カーソル設定
    [_csrPlay rangePointWithMax:_viewWaveImage.frame.size.width + _viewWaveImage.frame.origin.x Min:_viewWaveImage.frame.origin.x];
    [_csrPlay reloadViewFrameWithWaveFrame:_viewWaveImage.frame];
    
    // ループ範囲バー設定
    [_areaLoop reloadViewFrameWithWaveFrame:_viewWaveImage.frame];
    
    // サイレントエリア設定
    for (CursorArea *s in _arraySilent) {
        [s reloadViewFrameWithWaveFrame:_viewWaveImage.frame];
    }
}

#pragma mark - WaveImageView
/// 波形イメージビューの初期化処理
- (void) initWaveImageView {
    // 波形イメージビュー初期化
    _viewWaveImage = [[WaveformImageVew alloc] initWithFrame:CGRectMake(16, WAVE_MARGIN * 2, self.frame.size.width - 32, self.frame.size.height - WAVE_MARGIN * 3)];
    _viewWaveImage.userInteractionEnabled = YES;
    [self addSubview:_viewWaveImage];
    
    // 波形ビューに長押しジェスチャーを追加
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gestureLongPress:)];
    longPressGesture.minimumPressDuration = 0.5;
    longPressGesture.allowableMovement = 0.0;
    [_viewWaveImage addGestureRecognizer:longPressGesture];
}

/// 波形データの取り込み
- (void) loadWaveData: (NSURL *) url{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        dispatch_async(dispatch_get_main_queue(),^{
            // 波形の表示
            @try {
                _viewWaveImage.delegate = self;
                [_delegate startLoadingMusic];
                [_viewWaveImage imageUrl:url];
            }
            @catch (NSException *exception) {
                
                // 波形データを取得できなかったら
                [_delegate errorMusicPlayerView:MusicPlayerViewFailedLoadWaveImage];
            }
        });
    });
}

#pragma mark - PlayCursor
/// 再生カーソルの初期化処理
- (void) initPlayCursor {
    _csrPlay = [[PlayerCursorView alloc] initWithSuperView:self WaveView:_viewWaveImage];
    _csrPlay.delegate = self;
    _csrPlay.minimumPoint = _viewWaveImage.frame.origin.x;
    _csrPlay.maximumPoint = _viewWaveImage.frame.size.width + _viewWaveImage.frame.origin.x;
    [self addSubview:_csrPlay];
}

#pragma mark - LoopArea
/// ループエリアの初期化処理
- (void) initLoopArea {
    _areaLoop = [[CursorArea alloc] initWithSuperView:self WaveView:_viewWaveImage Mode:CursorAreaLoop];
    [self addDoubleTapGesture:_areaLoop.firstCursor];
    [self addDoubleTapGesture:_areaLoop.lastCursor];
    [self addDoubleTapGesture:_areaLoop.area];
}

#pragma mark - SilentArea
/// サイレントエリアの初期化・追加処理(座標)
- (CursorArea *) addSilentAreaWithFirstPoint: (float) first LastPoint: (float) last {
    CursorArea *s = [[CursorArea alloc] initWithSuperView:self WaveView:_viewWaveImage Mode:CursorAreaSilent];
    [s rangeValueWithMax:_csrMaximumValue Min:_csrMinimumValue];
    s.firstPoint = first;
    s.lastPoint = last;
    [self addDoubleTapGesture:s.firstCursor];
    [self addDoubleTapGesture:s.lastCursor];
    [self addDoubleTapGesture:s.area];
    [_arraySilent addObject:s];
    
    return s;
}

///　サイレントエリアの初期化・追加処理(値)
- (CursorArea *) addSilentAreaWithFirstValue: (float) first LastValue: (float) last {
    CursorArea *s = [[CursorArea alloc] initWithSuperView:self WaveView:_viewWaveImage Mode:CursorAreaSilent];
    [s rangeValueWithMax:_csrMaximumValue Min:_csrMinimumValue];
    s.firstValue = first;
    s.lastValue = last;
    [self addDoubleTapGesture:s.firstCursor];
    [self addDoubleTapGesture:s.lastCursor];
    [self addDoubleTapGesture:s.area];
    [_arraySilent addObject:s];
    
    return s;
}

/// サイレントエリア全削除
- (void) removeAllSilentArea {
    if (_arraySilent != nil) {
        for (CursorArea *s in _arraySilent) {
            [s.lastCursor removeFromSuperview];
            [s.firstCursor removeFromSuperview];
            [s.area removeFromSuperview];
        }
        _arraySilent = nil;
    }
    _arraySilent = [NSMutableArray new];
}

/// サイレントエリアの削除処理
- (void) longPressSilentArea {
    CursorArea *s = [_arraySilent objectAtIndex:_selectSilent];
    // 赤くする
    s.area.backgroundColor = [UIColor blueColor];
    
    CGSize btnsize = CGSizeMake(70, 20);
    
    _btnDltSilent = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _btnDltSilent.frame = CGRectMake(s.firstCursor.point + s.area.frame.size.width / 2, _viewWaveImage.center.y / 2, btnsize.width, btnsize.height);
    [_btnDltSilent setTitle:@"Delete" forState:UIControlStateNormal];
    _btnDltSilent.alpha = 0.8;
    _btnDltSilent.backgroundColor = [UIColor lightGrayColor];
    [_btnDltSilent setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_btnDltSilent addTarget:self action:@selector(onDeleteRemoveSilentArea:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:_btnDltSilent];
    
    _btnCxlSilent = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _btnCxlSilent.frame = CGRectMake(_btnDltSilent.frame.origin.x, _btnDltSilent.frame.origin.y + _btnDltSilent.frame.size.height + 5, btnsize.width, btnsize.height);
    [_btnCxlSilent setTitle:@"Cancel" forState:UIControlStateNormal];
    _btnCxlSilent.alpha = 0.8;
    _btnCxlSilent.backgroundColor = [UIColor lightGrayColor];
    [_btnCxlSilent setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_btnCxlSilent addTarget:self action:@selector(onCancelRemoveSilentArea:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:_btnCxlSilent];
}

/// サイレントエリアの削除処理(Delete押下時)
- (void) onDeleteRemoveSilentArea: (UIButton *) btn {
    CursorArea *s = [_arraySilent objectAtIndex:_selectSilent];
    [s.lastCursor removeFromSuperview];
    [s.firstCursor removeFromSuperview];
    [s.area removeFromSuperview];
    s = nil;
    [_arraySilent removeObjectAtIndex:_selectSilent];
    
    [_btnDltSilent removeFromSuperview];
    [_btnCxlSilent removeFromSuperview];
    _btnDltSilent = nil;
    _btnCxlSilent = nil;
}

/// サイレントエリアの削除処理(キャンセル押下時)
- (void) onCancelRemoveSilentArea: (UIButton *) btn {
    CursorArea *s = [_arraySilent objectAtIndex:_selectSilent];
    s.area.backgroundColor = [UIColor cyanColor];
    
    [_btnDltSilent removeFromSuperview];
    [_btnCxlSilent removeFromSuperview];
    _btnDltSilent = nil;
    _btnCxlSilent = nil;
}

/// サイレントエリア内かどうか判定
- (BOOL) inSilentRange {
    BOOL result = NO;
    
    for (CursorArea *s in _arraySilent) {
        if (_csrPlay.value <= s.lastCursor.value
            && _csrPlay.value >= s.firstCursor.value) {
            result = YES;
            break;
        }
    }
    
    return result;
}

#pragma mark - WaveformimageView Delegate
- (void) onCompleted {
    NSLog(@"Completed");
    // 波形取り込み完了時処理
    [_delegate completedLoadingMusic];
}

#pragma mark - PlayerCursorViewDelegate
-(void) changeValue:(UIView *)view {
    if (view == _csrPlay) {
        // 再生カーソルの値変更時処理
        [_delegate changePlayTime: _csrPlay.value];
    }
}

#pragma mark - Gesture
/// ビューにダブルタップジェスチャーを追加する
- (void) addDoubleTapGesture: (UIView *) view {
    // ジェスチャーの初期化
    UITapGestureRecognizer *doubleTapGesture;
    doubleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gestureDoubleTapped:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    
    [view addGestureRecognizer:doubleTapGesture];
}

/// ダブルタップ時の処理
- (void) gestureDoubleTapped:(UITapGestureRecognizer *)sender {
    CursorView *c = (CursorView *) sender.view;
    
    // ループ
    if (c == _areaLoop.firstCursor || c == _areaLoop.lastCursor) {
        // カーソル
        
        c.value = _csrPlay.value;
        
        if (_areaLoop.firstCursor.value > _areaLoop.lastCursor.value) {
            _areaLoop.lastCursor.value = _csrPlay.value;
        }
        
        if (c == _areaLoop.firstCursor) {
            _areaLoop.firstValue = c.value;
        } else {
            _areaLoop.lastValue = c.value;
        }
        
        
    } else if (c == _areaLoop.area) {
        // エリア
        
        float disf = fabs(_csrPlay.point - _areaLoop.firstCursor.point);
        float disl = fabs(_csrPlay.point - _areaLoop.lastCursor.point);
        
        if (disf < disl) {
            if (c.frame.size.width < _areaLoop.lastCursor.maximumPoint - _csrPlay.point) {
                _areaLoop.centerPoint = _csrPlay.point + c.frame.size.width / 2 - c.superview.frame.origin.x;
            }
        } else {
            if (c.frame.size.width < _csrPlay.point - _areaLoop.firstCursor.minimumPoint) {
                _areaLoop.centerPoint = _csrPlay.point - c.frame.size.width / 2 - c.superview.frame.origin.x;

            }
        }
    }
    
    // サイレント
    for (CursorArea *s in _arraySilent) {
        if (c == s.firstCursor || c == s.lastCursor) {
            // カーソル
            
            c.value = _csrPlay.value;
            
            if (s.firstCursor.value > s.lastCursor.value) {
                s.lastCursor.value = _csrPlay.value;
            }
            if (c == s.firstCursor) {
                s.firstValue = c.value;
            } else {
                s.lastValue = c.value;
            }
        } else if (c == s.area) {
            // エリア
            
            float disb = fabs(_csrPlay.point - s.firstCursor.point);
            float dise = fabs(_csrPlay.point - s.lastCursor.point);
            
            if (disb < dise) {
                if (c.frame.size.width < s.lastCursor.maximumPoint - _csrPlay.point) {
                    s.centerPoint = _csrPlay.point + c.frame.size.width / 2 - c.superview.frame.origin.x;
                }
            } else {
                if (c.frame.size.width < _csrPlay.point - s.firstCursor.minimumPoint) {
                    s.centerPoint = _csrPlay.point - c.frame.size.width / 2 - c.superview.frame.origin.x;
                }
            }
        }
    }
}

/// 長押し時の処理
- (void) gestureLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        // サイレントエリア削除ボタンと削除キャンセルボタンが表示されていない時
        if (_btnDltSilent == nil && _btnCxlSilent == nil) {
            
            float point = [sender locationInView:_viewWaveImage].x;
            int areaNum = -1;
            int areaWidth = -1;
            
            for (int i = 0; i < _arraySilent.count; i++) {
                CursorArea *s = [_arraySilent objectAtIndex:i];
                if (s.firstCursor.point <= point && s.lastCursor.point >= point) {
                    // サイレント区間に入っていれば
                    if (areaWidth != -1) {
                        if (areaWidth > s.lastCursor.point - s.firstCursor.point) {
                            // より短いサイレント区間があれば
                            areaNum = i;
                            areaWidth = s.lastCursor.point - s.firstCursor.point;
                        }
                    } else {
                        areaNum = i;
                        areaWidth = s.lastCursor.point - s.firstCursor.point;
                    }
                }
            }
            if (areaNum != -1) {
                _selectSilent = areaNum;
                [self longPressSilentArea];
                
            } else {
                // タップした位置にサイレント区間がなければ、追加
                // サイレントエリア数チェック
                if (_arraySilent.count < _productManager.silentArea) {
                    
                    [self addSilentAreaWithFirstPoint:point - 20 LastPoint:point + 20];
                    
                } else {
                    // サイレントエリア上限通知処理
                    [_delegate errorMusicPlayerView:MusicPlayerViewSilentFull];
                }
                
            }
        }
        
    }
}
@end
