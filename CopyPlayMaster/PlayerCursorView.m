//
//  PlayerCursorView.m
//  MediaPlayerTestSample
//
//  Created by user on 2015/02/26.
//  Copyright (c) 2015年 yamasaki. All rights reserved.
//

#import "PlayerCursorView.h"

@implementation PlayerCursorView

- (id) initWithSuperView: (UIView *) superview WaveView: (UIView *) waveview; {
    if (self = [super initWithFrame:CGRectMake(waveview.frame.origin.x, waveview.frame.origin.y + waveview.frame.size.height + ICON_MARGIN, ICON_SIZE, ICON_SIZE)]) {
        
        UIColor *color = [UIColor redColor];
        
        // サムの設定
        _thum = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2, -waveview.frame.size.height - ICON_MARGIN, 1, waveview.frame.size.height + ICON_MARGIN)];
        _thum.backgroundColor = color;
        [self addSubview:_thum];
        
//        TriangleView *mark = [[TriangleView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2 - MarkSize / 2, 0, MarkSize, MarkSize) Color:color];
//        [self addSubview:mark];
        
        UIImageView *image = [[UIImageView alloc] initWithFrame:self.bounds];
        image.image = [UIImage imageNamed:@"marker.png"];
        [self addSubview:image];
    }
    return self;
}

- (void) reloadViewFrameWithWaveFrame: (CGRect) waveframe {
    CGRect frame;
    
    // self
    frame = self.frame;
    frame.origin.x = waveframe.origin.x;
    frame.origin.y = waveframe.origin.y + waveframe.size.height + ICON_MARGIN;
    self.frame = frame;
    // thum
    frame = _thum.frame;
    frame.origin.y = -waveframe.size.height - ICON_MARGIN;
    frame.size.height = waveframe.size.height + ICON_MARGIN;
    _thum.frame = frame;
}

@end