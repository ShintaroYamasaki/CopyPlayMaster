//
//  ProductManager.h
//  MediaPlayerTestSample
//
//  Created by user on 2015/03/25.
//  Copyright (c) 2015年 yamasaki. All rights reserved.
//

#import <Foundation/Foundation.h>

// プロダクトID
#define kProductRemoveAd @"jp.cubic.CopyTrainingPlayer.removeAd"
#define kProductEnableSpeedChange @"jp.cubicinc.CopyTrainingPlayer.EnableSpeedChange"
#define kProductAddSaveSlot @"jp.cubicinc.CopyTrainingPlayer.AddSaveSlot"
#define kProductAddSilentArea @"jp.cubicinc.CopyTrainingPlayer.AddSilentArea"

@interface ProductManager : NSObject {
    NSUserDefaults *_userDefaults;
}

/// プロダクトID一覧
@property (nonatomic, readonly) NSMutableSet *productIds;
/// 広告の表示/非表示
@property (nonatomic) BOOL isRemoveAd;
/// スピード変更の有効/無効
@property (nonatomic) BOOL isSpeedChange;
/// 保存スロット数
@property (nonatomic) NSInteger saveSlot;
/// サイレントエリア数
@property (nonatomic) NSInteger silentArea;

+ (ProductManager *)sharedInstance;
/** 購入の反映 */
- (void)bought:(NSString *)productIds;

@end
