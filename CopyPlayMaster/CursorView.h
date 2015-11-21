//
//  TransformButton.h
//  TransformButtonTest
//
//  Created by user on 2015/02/12.
//  Copyright (c) 2015年 yamasaki. All rights reserved.
//

#import <UIKit/UIKit.h>

/// カーソルビューデリゲート
@protocol CursorViewDelegate <NSObject>

/// 値が変わった時
-(void) changeValue: (UIView *) view;
///// ダブルタップ時
//- (void) gestureDoubleTapped: (UIView *) view;

@end

/// カーソルビュー
@interface CursorView : UIView {

}

/// 座標
@property(nonatomic) float point;
/// 値
@property(nonatomic) float value;
/// 最小座標
@property(nonatomic) float minimumPoint;
/// 最大座標
@property(nonatomic) float maximumPoint;
/// 最小値
@property(nonatomic) float minimumValue;
/// 最大値
@property(nonatomic) float maximumValue;
/// シークビューデリゲート
@property(nonatomic) id<CursorViewDelegate> delegate;

/// 座標から値へ変換
- (float) toValueFromPoint: (float) point;
/// 値から座標へ変換
- (float) toPointFromValue: (float) value;
/// 最大座標・最小座標が変わった時
- (void) rangePointWithMax: (float) maximum Min: (float) minimum;
@end
