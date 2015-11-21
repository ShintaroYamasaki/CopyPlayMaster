//
//  TransformButton.m
//  TransformButtonTest
//
//  Created by user on 2015/02/12.
//  Copyright (c) 2015年 yamasaki. All rights reserved.
//

#import "CursorView.h"

@interface CursorView() {
    CGPoint startLocation;
}

@end

@implementation CursorView

/// 描画するビューを指定して初期化
- (id) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _point = 0;
        _value = 0;
        _minimumPoint = frame.origin.x;
        _maximumPoint = frame.size.width;
        _minimumValue = 0;
        _maximumValue = 1.0;
    }
    return self;
}

- (void) setPoint:(float)point {
    _point = point;
    CGRect frame = self.frame;
    frame.origin.x = point - frame.size.width / 2;
    self.frame = frame;
    _value = [self toValueFromPoint:_point];
}

- (void) setValue:(float)value {
    _value = value;
    [self setPoint: [self toPointFromValue:_value]];
    
}

- (float) toValueFromPoint: (float) point {
    float value;
    float duration = _maximumValue - _minimumValue;
    float width = _maximumPoint - _minimumPoint;
    
    if (duration != 0 && width != 0) {
        value = duration * (point - _minimumPoint) / width + _minimumValue;
    } else {
        value = _minimumValue;
    }
    
    return value;
}


- (float) toPointFromValue: (float) value {
    float point;
    float duration = _maximumValue - _minimumValue;
    float width = _maximumPoint - _minimumPoint;
    
    if (duration != 0 && width != 0) {
        point = width * (value - _minimumValue) / duration + _minimumPoint;
    } else {
        point = _minimumPoint;
    }
    
    return point;
}

- (void) rangePointWithMax: (float) maximum Min: (float) minimum {
    _maximumPoint = maximum;
    _minimumPoint = minimum;
    
    [self setPoint: [self toPointFromValue:_value]];
    
    
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    startLocation = [[touches anyObject] locationInView:self];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self superview] bringSubviewToFront:self];
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    
    CGRect frame = [self frame];
    frame.origin.x += location.x - startLocation.x;
    float point= frame.origin.x + frame.size.width / 2;
    
    if (point > _maximumPoint) point = _maximumPoint;
    if (point < _minimumPoint) point = _minimumPoint;
    
    self.value = [self toValueFromPoint:point];
    self.point = point;
    
    [_delegate changeValue:self];
}

@end
