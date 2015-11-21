//
//  InfoViewController.h
//  CopyTrainingPlayer
//
//  Created by user on 2015/04/07.
//  Copyright (c) 2015年 yamasaki. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MENU_HEIGHT 35
#define BAR_MARGIN 4
#define MENU_COMPONENT_WIDTH 45
#define MENU_FONT_SIZE 10

@interface InfoViewController : UIViewController {
    /// メニュービュー
    UIView *_viewMenu;
    /// backボタン
    UIButton *_btnBack;
    
    /// スクリーンサイズ
    CGSize _screenSize;
}

@end
