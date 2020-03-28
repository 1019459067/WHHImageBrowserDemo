//
//  YBIBIconManager.h
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2018/8/29.
//  Copyright © 2018年 波儿菜. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (YBImageBrowser)

/**
 获取图片便利构造方法

 @param name 图片名字
 @param bundle 资源对象
 @return 图片实例
 */
+ (instancetype)imageNamed:(NSString *)name bundle:(NSBundle *)bundle;

@end


/// 获取图片闭包
typedef UIImage * _Nullable (^YBIBIconBlock)(void);

/**
 图标管理类
 */
@interface YBIBIconManager : NSObject

/**
 唯一有效单例
 */
+ (instancetype)sharedManager;

#pragma - 以下图片可更改

/// 基本-加载
@property (nonatomic, copy) YBIBIconBlock loadingImage;
/// 视频-返回
@property (nonatomic, copy) YBIBIconBlock videoBackImage;
/// 视频-全屏
@property (nonatomic, copy) YBIBIconBlock fullScreenImage;
/// 视频-缩放
@property (nonatomic, copy) YBIBIconBlock zoomScreenImage;
/// 视频-开启声音
@property (nonatomic, copy) YBIBIconBlock openVolumeImage;
/// 视频-关闭声音
@property (nonatomic, copy) YBIBIconBlock closeVolumeImage;
/// 视频-播放
@property (nonatomic, copy) YBIBIconBlock videoPlayImage;
/// 视频-暂停
@property (nonatomic, copy) YBIBIconBlock videoPauseImage;
/// 视频-关闭
@property (nonatomic, copy) YBIBIconBlock videoCloseImage;
/// 视频-拖动圆点
@property (nonatomic, copy) YBIBIconBlock videoDragCircleImage;

@end

NS_ASSUME_NONNULL_END
