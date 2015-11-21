//
//  ProductManager.m
//  MediaPlayerTestSample
//
//  Created by user on 2015/03/25.
//  Copyright (c) 2015年 yamasaki. All rights reserved.
//

#import "ProductManager.h"

@implementation ProductManager

+ (ProductManager *)sharedInstance {
    static ProductManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[ProductManager alloc] init];
    });
    return _sharedInstance;
}

- (id) init {
    self = [super init];
    
    if (self != nil) {
        // プロダクトID一覧を作成
        _productIds = [[NSMutableSet alloc] init];
        [_productIds addObject:kProductRemoveAd];
        [_productIds addObject:kProductEnableSpeedChange];
        [_productIds addObject:kProductAddSaveSlot];
        [_productIds addObject:kProductAddSilentArea];
        
        // 購入状況をNSUserDefaultsから読み込む
        _userDefaults = [NSUserDefaults standardUserDefaults];
        _isRemoveAd = [_userDefaults boolForKey:kProductRemoveAd];
        _saveSlot = [_userDefaults integerForKey:kProductAddSaveSlot];
        if (_saveSlot == 0) {
            _saveSlot = 3;
        }
        _silentArea = [_userDefaults integerForKey:kProductAddSilentArea];
        if (_silentArea == 0) {
            _silentArea = 2;
        }
        _isSpeedChange = [_userDefaults boolForKey:kProductEnableSpeedChange];
    }
    
    return self;
}

- (void) setIsRemoveiAd:(BOOL)isRemoveAd {
    _isRemoveAd = isRemoveAd;
    // 購入状況をNSUserDefaultsに保存
    [_userDefaults setBool:isRemoveAd forKey:kProductRemoveAd];
    [_userDefaults synchronize];
}

- (void) setSaveSlot:(NSInteger)saveSlot {
    _saveSlot = saveSlot;
    // 購入状況をNSUserDefaultsに保存
    [_userDefaults setInteger:saveSlot forKey:kProductAddSaveSlot];
    [_userDefaults synchronize];
}

- (void) setSilentArea:(NSInteger)silentArea {
    _silentArea = silentArea;
    // 購入状況をNSUserDefaultsに保存
    [_userDefaults setInteger:silentArea forKey:kProductAddSilentArea];
    [_userDefaults synchronize];
}

- (void) setIsSpeedChange:(BOOL)isSpeedChange {
    _isSpeedChange = isSpeedChange;
    // 購入状況をNSUserDefaultsに保存
    [_userDefaults setBool:isSpeedChange forKey:kProductEnableSpeedChange];
    [_userDefaults synchronize];
}

- (void)bought:(NSString *)productIds {
    // 購入されたものをNSUserDefaultsで管理する
    // productIdsでプロダクトを識別
    if ([productIds isEqualToString:kProductRemoveAd]) {
        [self setIsRemoveiAd:YES];
    } else if ([productIds isEqualToString:kProductAddSaveSlot]) {
        [self setSaveSlot:_saveSlot + 1];
    } else if ([productIds isEqualToString:kProductAddSilentArea]) {
        [self setSilentArea:_silentArea + 1];
    } else if ([productIds isEqualToString:kProductEnableSpeedChange]) {
        [self setIsSpeedChange:YES];
    }
 }


@end
