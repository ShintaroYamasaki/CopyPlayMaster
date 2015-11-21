//
//  WaveformImageVew.h
//  MediaPlayerTestSample
//
//  Created by user on 2015/01/07.
//  Copyright (c) 2015年 yamasaki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@protocol WaveformImageViewDelegate <NSObject>
- (void) onCompleted;
@end

@interface WaveformImageVew : UIImageView
@property(nonatomic) id<WaveformImageViewDelegate> delegate;

-(id)initWithUrl:(NSURL*)url;
- (void) imageUrl: (NSURL*)url;
- (NSData *) renderPNGAudioPictogramLogForAsset:(AVURLAsset *)songAsset;
@end
