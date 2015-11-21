//
//  LoopArea.m
//  MediaPlayerTestSample
//
//  Created by user on 2015/02/24.
//  Copyright (c) 2015年 yamasaki. All rights reserved.
//

#import "CursorArea.h"

@implementation CursorArea

- (id) initWithSuperView: (UIView *) superview WaveView: (UIView *) waveview Mode:(CursorAreaMode)mode{
    if (self = [super init]) {
        _mode = mode;
        
        switch (mode) {
            case CursorAreaLoop:
                _color = [UIColor yellowColor];
                _maxdif = 5;
                _firstCursor = [[LoopCursorView alloc] initWithSuperView:superview WaveView:waveview Color:_color];
                _lastCursor = [[LoopCursorView alloc] initWithSuperView:superview WaveView:waveview Color:_color];
                break;
            case CursorAreaSilent:
                _color = [UIColor cyanColor];
                _maxdif = 0;
                _firstCursor = [[SilentCursorView alloc] initWithSuperView:superview WaveView:waveview Color:_color];
                _lastCursor = [[SilentCursorView alloc] initWithSuperView:superview WaveView:waveview Color:_color];
                break;
        }
        
        // 範囲ビュー
        _area = [[CursorView alloc] initWithFrame:waveview.bounds];
        _area.alpha = 0.2;
        _area.backgroundColor = _color;
        _area.minimumPoint = waveview.frame.origin.x + _area.frame.size.width / 2;
        _area.maximumPoint = waveview.frame.origin.x + waveview.frame.size.width - _area.frame.size.width / 2;
        _area.delegate = self;
        [waveview addSubview:_area];
        [[_area superview] bringSubviewToFront:_area];
        
        // 始点カーソル
        _firstCursor.minimumPoint = waveview.frame.origin.x;
        _firstCursor.maximumPoint = waveview.frame.size.width + waveview.frame.origin.x;
        _firstCursor.delegate = self;
        [superview addSubview:_firstCursor];
        
        // 終点カーソル
        _lastCursor.minimumPoint = waveview.frame.origin.x;
        _lastCursor.maximumPoint = waveview.frame.size.width + waveview.frame.origin.x;
        _lastCursor.delegate = self;
        [superview addSubview:_lastCursor];
        
    }
    
    return self;
}

/// 範囲変更
- (void) changeArea: (CursorView *) view{
    // 引数が始点カーソルまたは終点カーソルであるかどうか
    if (view != _firstCursor && view != _lastCursor && view != _area) {
        return;
    }
    
    if (view == _firstCursor || view == _lastCursor) {
        // カーソル操作
        
        float start = _firstCursor.point;
        float end = _lastCursor.point;
        float width = end - start;
        
        // 始点と終点の間隔を0にしない
        if (width <= _maxdif) {
            if (view == _firstCursor) {
                if (_lastCursor.point >= _lastCursor.maximumPoint) {
                    _lastCursor.point = _lastCursor.maximumPoint;
                    _firstCursor.point = _lastCursor.point - _maxdif;
                } else {
                    _lastCursor.point = _firstCursor.point + _maxdif;
                }
            } else  if (view == _lastCursor){
                if (_firstCursor.point <= _firstCursor.minimumPoint) {
                    _firstCursor.point = _firstCursor.minimumPoint;
                    _lastCursor.point = _firstCursor.point + _maxdif;
                } else {
                    _firstCursor.point = _lastCursor.point - _maxdif;
                }
            }
            
            start = _firstCursor.point;
            end = _lastCursor.point;
            width = _maxdif;
        }
        
        _area.minimumPoint = width / 2;
        _area.maximumPoint = _area.superview.frame.size.width - width / 2;
        
        CGRect frame = [_area frame];
        frame.origin.x = start - [_area superview].frame.origin.x;
        frame.size.width = width;
//        frame.size.height = [_area superview].frame.size.height;
        _area.frame = frame;
    } else {
        // エリア操作
        
        float width = _area.frame.size.width;
        _firstCursor.point = _area.point - width / 2 + _area.superview.frame.origin.x;
        _lastCursor.point = _area.point + width / 2 + _area.superview.frame.origin.x;
        
        if (_firstCursor.point <= _firstCursor.minimumPoint) {
            _firstCursor.point = _firstCursor.minimumPoint;
            [self changeArea:_firstCursor];
        } else  if (_lastCursor.point >= _lastCursor.maximumPoint){
            _lastCursor.point = _lastCursor.maximumPoint;
            [self changeArea:_lastCursor];
        }

        
        if (_mode == CursorAreaLoop) {
            [_area.superview sendSubviewToBack:_area];
        } else if (_mode == CursorAreaSilent) {
            [_area.superview bringSubviewToFront:_area];
        }
    }
    
}

- (void) rangeValueWithMax: (float) maximum Min: (float) minimum {
    _firstCursor.maximumValue = maximum;
    _firstCursor.minimumValue = minimum;
    _firstCursor.value = minimum;
    _lastCursor.maximumValue = maximum;
    _lastCursor.minimumValue = minimum;
    _lastCursor.value = maximum;
    [self changeArea:_firstCursor];
}

- (void) reloadViewFrameWithWaveFrame:(CGRect) waveframe {
    [_firstCursor rangePointWithMax:waveframe.size.width + waveframe.origin.x Min:waveframe.origin.x];
    [_lastCursor rangePointWithMax:[_area superview].frame.size.width + [_area superview].frame.origin.x Min:[_area superview].frame.origin.x];
    [_area rangePointWithMax:waveframe.origin.x + waveframe.size.width - _area.frame.size.width / 2 Min:waveframe.origin.x + _area.frame.size.width / 2];
    
    if (_mode == CursorAreaSilent) {
        [(SilentCursorView *)_firstCursor reloadViewFrameWithWaveFrame:waveframe];
        [(SilentCursorView *)_lastCursor reloadViewFrameWithWaveFrame:waveframe];
    } else if (_mode == CursorAreaLoop) {
        [(LoopCursorView *)_firstCursor reloadViewFrameWithWaveFrame:waveframe];
        [(LoopCursorView *)_lastCursor reloadViewFrameWithWaveFrame:waveframe];
    }
    
    CGRect frame;
    frame = _area.frame;
    frame.size.height = waveframe.size.height;
    _area.frame = frame;
    
    [self changeArea:_firstCursor];
}

#pragma mark - setter
- (void) setFirstPoint:(float)firstPoint {
    _firstPoint = firstPoint;
    _firstCursor.point = firstPoint;
    _firstValue = _firstCursor.value;
    [self changeArea:_firstCursor];
}

- (void) setLastPoint:(float)lastPoint {
    _lastPoint = lastPoint;
    _lastCursor.point = lastPoint;
    _lastValue = _lastCursor.value;
    [self changeArea:_lastCursor];
}

- (void) setCenterPoint:(float)centerPoint {
    _centerPoint = centerPoint;
    _area.point = centerPoint;
    _centerValue = _area.value;
    [self changeArea:_area];
}

- (void) setFirstValue:(float)firstValue {
    _firstValue = firstValue;
    _firstCursor.value = firstValue;
    _firstPoint = _firstCursor.point;
    [self changeArea:_firstCursor];
}

- (void) setLastValue:(float)lastValue {
    _lastValue = lastValue;
    _lastCursor.value = lastValue;
    _lastPoint = _lastCursor.point;
    [self changeArea:_lastCursor];
}

- (void) setCenterValue:(float)centerValue {
    _centerValue = centerValue;
    _area.value = centerValue;
    _centerPoint = _area.value;
    [self changeArea:_area];
}

#pragma mark - CursorViewDelegate
- (void) changeValue:(UIView *)view {
    [self changeArea:(CursorView *) view];
}

@end
