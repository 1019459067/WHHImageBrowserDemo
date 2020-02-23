//
//  YBIBVideoActionBar.m
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/7/11.
//  Copyright © 2019 杨波. All rights reserved.
//

#import "YBIBVideoActionBar.h"
#import "YBIBIconManager.h"

@implementation YBVideoBrowseActionSlider
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setThumbImage:YBIBIconManager.sharedManager.videoDragCircleImage() forState:UIControlStateNormal];
        self.minimumTrackTintColor = UIColor.whiteColor;
        self.maximumTrackTintColor = [UIColor.whiteColor colorWithAlphaComponent:0.5];
        self.layer.shadowColor = UIColor.darkGrayColor.CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 1);
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 4;
        self.userInteractionEnabled = NO;
    }
    return self;
}
- (CGRect)trackRectForBounds:(CGRect)bounds {
    CGRect frame = [super trackRectForBounds:bounds];
    return CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 2);
}
- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    CGRect frame = [super thumbRectForBounds:bounds trackRect:rect value:value];
    return CGRectMake(frame.origin.x - 10, frame.origin.y - 10, frame.size.width + 20, frame.size.height + 20);
}
@end


@interface YBIBVideoActionBar ()
@property (nonatomic, strong) UILabel *preTimeLabel;
@property (nonatomic, strong) UILabel *sufTimeLabel;
@property (nonatomic, strong) UIButton *volumeButton;
@end

@implementation YBIBVideoActionBar {
    BOOL _dragging;
}

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _dragging = NO;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];

        [self addSubview:self.playButton];
        [self addSubview:self.preTimeLabel];
        [self addSubview:self.sufTimeLabel];
        [self addSubview:self.screenButton];
        [self addSubview:self.volumeButton];
        [self addSubview:self.slider];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.bounds.size.width, height = self.bounds.size.height;
    CGFloat labelWidth = 40, buttonWidth = 35, offset = 8;
    self.playButton.frame = CGRectMake(offset, 0, buttonWidth, height);
    self.preTimeLabel.frame = CGRectMake(CGRectGetMaxX(self.playButton.frame), 0, labelWidth, height);
    
    self.volumeButton.frame = CGRectMake(width - buttonWidth - offset, 0, buttonWidth, height);
    self.screenButton.frame = CGRectMake(CGRectGetMinX(self.volumeButton.frame) - buttonWidth, 0, buttonWidth, height);
    self.sufTimeLabel.frame = CGRectMake(CGRectGetMinX(self.screenButton.frame) - labelWidth, 0, labelWidth, height);
    self.slider.frame = CGRectMake(CGRectGetMaxX(self.preTimeLabel.frame), 0, CGRectGetMinX(self.sufTimeLabel.frame) - CGRectGetMaxX(self.preTimeLabel.frame), height);
}

#pragma mark - public

+ (CGFloat)defaultHeight {
    return 44;
}

- (void)setMaxValue:(float)value {
    self.slider.maximumValue = value;
    self.sufTimeLabel.attributedText = [self.class timeformatFromSeconds:value];
}

- (void)setCurrentValue:(float)value {
    if (!_dragging) {
        [self.slider setValue:value animated:YES];
    }
    self.preTimeLabel.attributedText = [self.class timeformatFromSeconds:value];
}

- (void)pause {
    self.playButton.selected = NO;
}

- (void)play {
    _dragging = NO;
    self.playButton.selected = YES;
}

#pragma mark - private

+ (NSAttributedString *)timeformatFromSeconds:(NSInteger)seconds {
    NSInteger hour = seconds / 3600, min = (seconds % 3600) / 60, sec = seconds % 60;
    NSString *text = seconds > 3600 ? [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hour, (long)min, (long)sec] : [NSString stringWithFormat:@"%02ld:%02ld", (long)min, (long)sec];
    
    NSShadow *shadow = [NSShadow new];
    shadow.shadowBlurRadius = 4;
    shadow.shadowOffset = CGSizeMake(0, 1);
    shadow.shadowColor = UIColor.darkGrayColor;
    NSAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSShadowAttributeName:shadow, NSFontAttributeName:[UIFont boldSystemFontOfSize:11]}];
    return attr;
}

#pragma mark - touch event

- (void)clickScreenButton:(UIButton *)button
{
    button.userInteractionEnabled = NO;
    button.selected = !button.selected;
    [YBIBUtilities sharedInstance].bFullScreen = button.selected;

    [self.delegate yb_videoActionBar:self clickScreenButton:button];
    button.userInteractionEnabled = YES;
}

- (void)clickVolumeButton:(UIButton *)button
{
    button.userInteractionEnabled = NO;
    [self.delegate yb_videoActionBar:self clickVolumeButton:button];
    button.userInteractionEnabled = YES;
}

- (void)clickPlayButton:(UIButton *)button {
    button.userInteractionEnabled = NO;
    if (button.selected) {
        [self.delegate yb_videoActionBar:self clickPauseButton:button];
    } else {
        [self.delegate yb_videoActionBar:self clickPlayButton:button];
    }
    button.userInteractionEnabled = YES;
}

- (void)respondsToSliderTouchFinished:(UISlider *)slider {
    [self.delegate yb_videoActionBar:self changeValue:slider.value];
}

- (void)respondsToSliderTouchDown:(UISlider *)slider {
    _dragging = YES;
}

#pragma mark - getters

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:YBIBIconManager.sharedManager.videoPlayImage() forState:UIControlStateNormal];
        [_playButton setImage:YBIBIconManager.sharedManager.videoPauseImage() forState:UIControlStateSelected];
        [_playButton addTarget:self action:@selector(clickPlayButton:) forControlEvents:UIControlEventTouchUpInside];
        _playButton.layer.shadowColor = UIColor.darkGrayColor.CGColor;
        _playButton.layer.shadowOffset = CGSizeMake(0, 1);
        _playButton.layer.shadowOpacity = 1;
        _playButton.layer.shadowRadius = 4;
    }
    return _playButton;
}

- (UIButton *)screenButton {
    if (!_screenButton) {
        _screenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_screenButton setImage:YBIBIconManager.sharedManager.fullScreenImage() forState:UIControlStateNormal];
        [_screenButton setImage:YBIBIconManager.sharedManager.zoomScreenImage() forState:UIControlStateSelected];
        [_screenButton addTarget:self action:@selector(clickScreenButton:) forControlEvents:UIControlEventTouchUpInside];
        _screenButton.layer.shadowColor = UIColor.darkGrayColor.CGColor;
        _screenButton.layer.shadowOffset = CGSizeMake(0, 1);
        _screenButton.layer.shadowOpacity = 1;
        _screenButton.layer.shadowRadius = 4;
    }
    return _screenButton;
}

- (UIButton *)volumeButton {
    if (!_volumeButton) {
        _volumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_volumeButton setImage:YBIBIconManager.sharedManager.openVolumeImage() forState:UIControlStateNormal];
        [_volumeButton setImage:YBIBIconManager.sharedManager.closeVolumeImage() forState:UIControlStateSelected];
        [_volumeButton addTarget:self action:@selector(clickVolumeButton:) forControlEvents:UIControlEventTouchUpInside];
        _volumeButton.layer.shadowColor = UIColor.darkGrayColor.CGColor;
        _volumeButton.layer.shadowOffset = CGSizeMake(0, 1);
        _volumeButton.layer.shadowOpacity = 1;
        _volumeButton.layer.shadowRadius = 4;
    }
    return _volumeButton;
}

- (UILabel *)preTimeLabel {
    if (!_preTimeLabel) {
        _preTimeLabel = [UILabel new];
        _preTimeLabel.attributedText = [self.class timeformatFromSeconds:0];
        _preTimeLabel.adjustsFontSizeToFitWidth = YES;
        _preTimeLabel.textAlignment = NSTextAlignmentCenter;
        _preTimeLabel.textColor = [UIColor.whiteColor colorWithAlphaComponent:0.9];
    }
    return _preTimeLabel;
}

- (UILabel *)sufTimeLabel {
    if (!_sufTimeLabel) {
        _sufTimeLabel = [UILabel new];
        _sufTimeLabel.attributedText = [self.class timeformatFromSeconds:0];
        _sufTimeLabel.adjustsFontSizeToFitWidth = YES;
        _sufTimeLabel.textAlignment = NSTextAlignmentCenter;
        _sufTimeLabel.textColor = [UIColor.whiteColor colorWithAlphaComponent:0.9];
    }
    return _sufTimeLabel;
}

- (YBVideoBrowseActionSlider *)slider {
    if (!_slider) {
        _slider = [YBVideoBrowseActionSlider new];
        [_slider addTarget:self action:@selector(respondsToSliderTouchFinished:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchCancel|UIControlEventTouchUpOutside];
        [_slider addTarget:self action:@selector(respondsToSliderTouchDown:) forControlEvents:UIControlEventTouchDown];
    }
    return _slider;
}

- (BOOL)isTouchInside {
    return self.slider.isTouchInside;
}

@end
