//
//  TriangleView.m
//  CopyTrainingPlayer
//
//  Created by user on 2015/03/26.
//  Copyright (c) 2015年 yamasaki. All rights reserved.
//

#import "TriangleView.h"

@implementation TriangleView

- (id)initWithFrame:(CGRect)frame Color:(UIColor *)color {
    self = [super initWithFrame:frame];
    if (self) {
        // 背景を透明にする
        self.backgroundColor = [UIColor clearColor];
        
        _color = color;
    }
    return self;
}
- (void)drawRect:(CGRect)rect
{
    // 塗りつぶす色を設定する。
    [_color setFill];
    
    // 三角形のパスを書く　（３点でオープンパスにした。）
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    CGContextMoveToPoint(ctx, width / 2, 0);
    CGContextAddLineToPoint(ctx, width, height);
    CGContextAddLineToPoint(ctx, 0, height);
    
    // 塗りつぶす
    CGContextFillPath(ctx);
}

@end
