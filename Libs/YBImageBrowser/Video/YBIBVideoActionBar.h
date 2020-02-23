//
//  YBIBVideoActionBar.h
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/7/11.
//  Copyright © 2019 杨波. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YBIBUtilities.h"

NS_ASSUME_NONNULL_BEGIN

@class YBIBVideoActionBar;

@protocol YBIBVideoActionBarDelegate <NSObject>
@required

- (void)yb_videoActionBar:(YBIBVideoActionBar *)actionBar clickPlayButton:(UIButton *)sender;

- (void)yb_videoActionBar:(YBIBVideoActionBar *)actionBar clickPauseButton:(UIButton *)sender;

- (void)yb_videoActionBar:(YBIBVideoActionBar *)actionBar changeValue:(float)value;

- (void)yb_videoActionBar:(YBIBVideoActionBar *)actionBar clickVolumeButton:(UIButton *)sender;

- (void)yb_videoActionBar:(YBIBVideoActionBar *)actionBar clickScreenButton:(UIButton *)sender;

@end

@interface YBVideoBrowseActionSlider : UISlider
@end

@interface YBIBVideoActionBar : UIView

@property (nonatomic, weak) id<YBIBVideoActionBarDelegate> delegate;

@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *screenButton;
@property (nonatomic, strong) YBVideoBrowseActionSlider *slider;

- (void)setMaxValue:(float)value;

- (void)setCurrentValue:(float)value;

- (void)pause;

- (void)play;

- (void)clickScreenButton:(UIButton *)button;

+ (CGFloat)defaultHeight;

@property (nonatomic, assign, readonly) BOOL isTouchInside;

@end

NS_ASSUME_NONNULL_END
