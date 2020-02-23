//
//  YBIBVideoView.m
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/7/11.
//  Copyright © 2019 杨波. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "YBIBVideoView.h"
#import "YBIBVideoActionBar.h"
#import "YBIBVideoTopBar.h"
#import "YBIBUtilities.h"
#import "YBIBIconManager.h"

@interface YBIBVideoView () <YBIBVideoActionBarDelegate>
@property (nonatomic, strong) YBIBVideoTopBar *topBar;
@property (nonatomic, strong) YBIBVideoActionBar *actionBar;

@property (strong, nonatomic) AVPlayerItem *playerItem;

@property (nonatomic, assign) CGFloat curruntVolumeValue; ///< 记录系统声音

@end

@implementation YBIBVideoView {    
    AVPlayerLayer *_playerLayer;
    BOOL _active;
}

#pragma mark - life cycle

- (void)dealloc {
    [self removeObserverForSystem];
    [self reset];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initValue];
        self.backgroundColor = UIColor.clearColor;
        
        [self addSubview:self.thumbImageView];
        [self addSubview:self.topBar];
        [self addSubview:self.actionBar];
        [self addObserverForSystem];
        
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToTapGesture:)];
        [self addGestureRecognizer:_tapGesture];
    }
    return self;
}

- (void)initValue {
    _playing = NO;
    _active = YES;
    _needAutoPlay = YES;
    _autoPlayCount = 0;
    _playFailed = NO;
    _preparingPlay = NO;
}

#pragma mark - public

- (void)updateLayoutWithExpectOrientation:(UIDeviceOrientation)orientation containerSize:(CGSize)containerSize {
    UIEdgeInsets padding = YBIBPaddingByBrowserOrientation(orientation);
    CGFloat width = containerSize.width - padding.left - padding.right, height = containerSize.height;
    self.topBar.frame = CGRectMake(padding.left, padding.top, width, [YBIBVideoTopBar defaultHeight]);
    self.actionBar.frame = CGRectMake(padding.left, height - [YBIBVideoActionBar defaultHeight] - padding.bottom, width, [YBIBVideoActionBar defaultHeight]);
    _playerLayer.frame = (CGRect){CGPointZero, containerSize};
}

- (void)reset {
    [self removeObserverForPlayer];
    
    // If set '_playerLayer.player = nil' or '_player = nil', can not cancel observeing of 'addPeriodicTimeObserverForInterval'.
    [_player pause];
    self.playerItem = nil;
    [_playerLayer removeFromSuperlayer];
    _playerLayer = nil;

    [self finishPlay];
}

- (void)hideToolBar:(BOOL)hide {
    if (hide) {
        self.actionBar.hidden = YES;
        self.topBar.hidden = YES;
    } else {
        self.actionBar.hidden = NO;
        self.topBar.hidden = NO;
    }
}


#pragma mark - private

- (void)videoJumpWithScale:(float)scale {
    CMTime startTime = CMTimeMakeWithSeconds(scale, _player.currentTime.timescale);
    AVPlayer *tmpPlayer = _player;
    
    if (CMTIME_IS_INDEFINITE(startTime) || CMTIME_IS_INVALID(startTime)) return;
    [_player seekToTime:startTime toleranceBefore:CMTimeMake(1, 1000) toleranceAfter:CMTimeMake(1, 1000) completionHandler:^(BOOL finished) {
        if (finished && tmpPlayer == self->_player) {
            [self startPlay];
        }
    }];
}

- (void)preparPlay {
    _preparingPlay = YES;
    _playFailed = NO;
        
    [self.delegate yb_preparePlayForVideoView:self];
    
    if (!_playerLayer) {
        self.playerItem = [AVPlayerItem playerItemWithAsset:self.asset];
        _player = [AVPlayer playerWithPlayerItem:self.playerItem];
        
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        _playerLayer.frame = (CGRect){CGPointZero, [self.delegate yb_containerSizeForVideoView:self]};
        [self.layer insertSublayer:_playerLayer above:self.thumbImageView.layer];
       
        self.curruntVolumeValue = _player.volume;

        [self addObserverForPlayer];
    } else {
        [self videoJumpWithScale:0];
    }
}

- (void)startPlay {
    if (_player) {
        _playing = YES;
        
        [_player play];
        [self.actionBar play];
        
        self.actionBar.hidden = NO;
        
        [self.delegate yb_startPlayForVideoView:self];
    }
}

- (void)finishPlay {
    self.actionBar.playButton.selected = NO;
    _playing = NO;
    [YBIBUtilities sharedInstance].bFinishedPlay = YES;
    
    [self.delegate yb_finishPlayForVideoView:self];
}

- (void)playerPause {
    if (_player) {
        [_player pause];
        [self.actionBar pause];
    }
}

- (BOOL)autoPlay {
    if (self.autoPlayCount == NSUIntegerMax) {
        [self preparPlay];
    } else if (self.autoPlayCount > 0) {
        --self.autoPlayCount;
        [self.delegate yb_autoPlayCountChanged:self.autoPlayCount];
        [self preparPlay];
    } else {
        return NO;
    }
    return YES;
}

#pragma mark - <YBIBVideoActionBarDelegate>

- (void)yb_videoActionBar:(YBIBVideoActionBar *)actionBar clickPlayButton:(UIButton *)sender {
    if ([YBIBUtilities sharedInstance].bFinishedPlay == YES) {
        [self clickPlayButton:nil];
    } else {
        [self startPlay];
    }
    [YBIBUtilities sharedInstance].bFinishedPlay = NO;
}

- (void)yb_videoActionBar:(YBIBVideoActionBar *)actionBar clickPauseButton:(UIButton *)sender {
    [self playerPause];
}

- (void)yb_videoActionBar:(YBIBVideoActionBar *)actionBar changeValue:(float)value {
    [self videoJumpWithScale:value];
}

- (void)yb_videoActionBar:(YBIBVideoActionBar *)actionBar clickVolumeButton:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.isSelected == YES) {
        _player.volume = 0;
    } else {
        _player.volume = self.curruntVolumeValue;
    }
}

- (void)yb_videoActionBar:(YBIBVideoActionBar *)actionBar clickScreenButton:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(yb_videoView:didClickedFullScreen:)]) {
        [self.delegate yb_videoView:self didClickedFullScreen:sender.selected];
    }
}

#pragma mark - observe

- (void)addObserverForPlayer {
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    __weak typeof(self) wSelf = self;
    [_player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1000.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        __strong typeof(wSelf) self = wSelf;
        if (!self) return;
        float currentTime = (time.value) / (CGFloat)time.timescale;

        if (currentTime == 0) {
            self.actionBar.slider.value = 0;
        }
        [self.actionBar setCurrentValue:currentTime];
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
}

- (void)removeObserverForPlayer {
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (![self.delegate yb_isFreezingForVideoView:self]) {
        if (object == self.playerItem) {
            if ([keyPath isEqualToString:@"status"]) {
                [self playerItemStatusChanged];
            }
        }
    }
}

- (void)didPlayToEndTime:(NSNotification *)noti {
    if (noti.object == self.playerItem) {
        [self finishPlay];
        [self.delegate yb_didPlayToEndTimeForVideoView:self];
    }
}

- (void)playerItemStatusChanged {
    if (!_active) return;
    
    _preparingPlay = NO;
    
    switch (self.playerItem.status) {
        case AVPlayerItemStatusReadyToPlay: {
            // Delay to update UI.
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self startPlay];
                double max = CMTimeGetSeconds(self.playerItem.duration);
                [self.actionBar setMaxValue:(isnan(max) || isinf(max)) ? 0 : max];
            });
        }
            break;
        case AVPlayerItemStatusUnknown: {
            _playFailed = YES;
            [self.delegate yb_playFailedForVideoView:self];
            [self reset];
        }
            break;
        case AVPlayerItemStatusFailed: {
            _playFailed = YES;
            [self.delegate yb_playFailedForVideoView:self];
            [self reset];
        }
            break;
    }
}

- (void)removeObserverForSystem {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
}

- (void)addObserverForSystem {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarFrame) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:)   name:AVAudioSessionRouteChangeNotification object:nil];
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    _active = NO;
    [self playerPause];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    _active = YES;
}

- (void)didChangeStatusBarFrame {
    if ([UIApplication sharedApplication].statusBarFrame.size.height > YBIBStatusbarHeight()) {
        [self playerPause];
    }
}

- (void)audioRouteChangeListenerCallback:(NSNotification*)notification {
    YBIB_DISPATCH_ASYNC_MAIN(^{
        NSDictionary *interuptionDict = notification.userInfo;
        NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
        switch (routeChangeReason) {
            case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
                [self playerPause];
                break;
        }
    })
}

#pragma mark - event

- (void)respondsToTapGesture:(UITapGestureRecognizer *)tap {
    if (self.isPlaying) {
        self.actionBar.hidden = !self.actionBar.isHidden;
    } else {
        [self.delegate yb_respondsToTapGestureForVideoView:self];
    }
}

- (void)clickCancelButton:(UIButton *)button {
    if ([YBIBUtilities sharedInstance].bFullScreen == NO) {
        [self.delegate yb_cancelledForVideoView:self];
    }else {
        [self.actionBar clickScreenButton:self.actionBar.screenButton];
    }
}

- (void)clickPlayButton:(UIButton *)button {
    [self preparPlay];
}

#pragma mark - getters & setters

- (void)setNeedAutoPlay:(BOOL)needAutoPlay {
    if (needAutoPlay && _asset && !self.isPlaying) {
        [self autoPlay];
    } else {
        _needAutoPlay = needAutoPlay;
    }
}

@synthesize asset = _asset;
- (void)setAsset:(AVAsset *)asset {
    _asset = asset;
    if (!asset) return;
}
- (AVAsset *)asset {
    if ([_asset isKindOfClass:AVURLAsset.class]) {
        _asset = [AVURLAsset assetWithURL:((AVURLAsset *)_asset).URL];
    }
    return _asset;
}

- (YBIBVideoTopBar *)topBar {
    if (!_topBar) {
        _topBar = [YBIBVideoTopBar new];
        [_topBar.cancelButton addTarget:self action:@selector(clickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _topBar;
}

- (YBIBVideoActionBar *)actionBar {
    if (!_actionBar) {
        _actionBar = [YBIBVideoActionBar new];
        _actionBar.delegate = self;
        _actionBar.hidden = YES;
    }
    return _actionBar;
}

- (UIImageView *)thumbImageView {
    if (!_thumbImageView) {
        _thumbImageView = [UIImageView new];
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFit;
        _thumbImageView.layer.masksToBounds = YES;
    }
    return _thumbImageView;
}

@end
