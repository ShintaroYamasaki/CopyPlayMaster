//
//  OptionCursorView.m
//  MediaPlayerTestSample
//
//  Created by user on 2015/02/26.
//  Copyright (c) 2015年 yamasaki. All rights reserved.
//

#import "SilentCursorView.h"

@implementation SilentCursorView

- (id) initWithSuperView: (UIView *) superview WaveView: (UIView *) waveview Color: (UIColor *) color; {
    if (self = [super initWithFrame:CGRectMake(waveview.frame.origin.x, waveview.frame.origin.y - WAVE_MARGIN, ICON_SIZE, ICON_SIZE)]) {
        
        // サムの設定
        _thum = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2, ICON_SIZE, 1, waveview.frame.size.height + ICON_MARGIN)];
        _thum.backgroundColor = color;
        [self addSubview:_thum];
        
//        TriangleView *mark = [[TriangleView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2 - MarkSize / 2, self.frame.size.height - MarkSize, MarkSize, MarkSize) Color:color];
//        CGAffineTransform t1 = CGAffineTransformMakeTranslation(0, 0);
//        CGAffineTransform t2 = CGAffineTransformRotate(t1, M_PI);
//        
//        mark.transform = t2;
//        
//        [self addSubview:mark];
        
        UIImageView *image = [[UIImageView alloc] initWithFrame:self.bounds];
        image.image = [UIImage imageNamed:@"marker-silent.png"];
        [self addSubview:image];

    }
    return self;
}

/// フレーム更新
- (void) reloadViewFrameWithWaveFrame: (CGRect) waveframe {
    CGRect frame;
    
    // thum
    frame = _thum.frame;
    frame.size.height = waveframe.size.height + ICON_MARGIN;
    _thum.frame = frame;
}

@end
