//
//  YBIBIconManager.m
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2018/8/29.
//  Copyright © 2018年 波儿菜. All rights reserved.
//

#import "YBIBIconManager.h"

// The best order for path scale search.
static NSArray *_NSBundlePreferredScales() {
    static NSArray *scales;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat screenScale = [UIScreen mainScreen].scale;
        if (screenScale <= 1) {
            scales = @[@1,@2,@3];
        } else if (screenScale <= 2) {
            scales = @[@2,@3,@1];
        } else {
            scales = @[@3,@2,@1];
        }
    });
    return scales;
}

// Add scale modifier to the file name (without path extension), from @"name" to @"name@2x".
static NSString *_NSStringByAppendingNameScale(NSString *string, CGFloat scale) {
    if (!string) return nil;
    if (fabs(scale - 1) <= __FLT_EPSILON__ || string.length == 0 || [string hasSuffix:@"/"]) return string.copy;
    return [string stringByAppendingFormat:@"@%@x", @(scale)];
}

@implementation UIImage (YBImageBrowser)

+ (instancetype)imageNamed:(NSString *)name bundle:(NSBundle *)bundle {
    if (name.length == 0) return nil;
    if ([name hasSuffix:@"/"]) return nil;
    
    NSString *res = name.stringByDeletingPathExtension;
    NSString *ext = name.pathExtension;
    NSString *path = nil;
    CGFloat scale = 1;
    
    // If no extension, guess by system supported (same as UIImage).
    NSArray *exts = ext.length > 0 ? @[ext] : @[@"", @"png", @"jpeg", @"jpg", @"gif", @"webp", @"apng"];
    NSArray *scales = _NSBundlePreferredScales();
    for (int s = 0; s < scales.count; s++) {
        scale = ((NSNumber *)scales[s]).floatValue;
        NSString *scaledName = _NSStringByAppendingNameScale(res, scale);
        for (NSString *e in exts) {
            path = [bundle pathForResource:scaledName ofType:e];
            if (path) break;
        }
        if (path) break;
    }
    if (path.length == 0) {
        // Assets.xcassets supported.
        return [self imageNamed:name];
    }
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data.length == 0) return nil;
    
    return [[self alloc] initWithData:data scale:scale];
}

@end


@implementation YBIBIconManager

+ (instancetype)sharedManager {
    static YBIBIconManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [YBIBIconManager new];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _loadingImage = ^UIImage * _Nullable{
            return [UIImage imageNamed:@"icon_play_loading"];
        };
        
        _videoBackImage = ^UIImage * _Nullable{
            return [UIImage imageNamed:@"icon_back_white"];
        };
        
        _fullScreenImage = ^UIImage * _Nullable{
            return [UIImage imageNamed:@"icon_openscreen"];
        };
        _zoomScreenImage = ^UIImage * _Nullable{
            return [UIImage imageNamed:@"icon_shrinkscreen"];
        };
        _openVolumeImage = ^UIImage * _Nullable{
            return [UIImage imageNamed:@"icon_openvolume"];
        };
        _closeVolumeImage = ^UIImage * _Nullable{
            return [UIImage imageNamed:@"icon_closevolume"];
        };
        _videoPlayImage = ^UIImage * _Nullable{
            return [UIImage imageNamed:@"icon_play_30x42"];
        };
        _videoPauseImage = ^UIImage * _Nullable{
            return [UIImage imageNamed:@"icon_pause"];
        };
        _videoCloseImage = ^UIImage * _Nullable{
            return [UIImage imageNamed:@"icon_close_33"];
        };
        _videoDragCircleImage = ^UIImage * _Nullable{
            return [UIImage imageNamed:@"icon_player_dot"];
        };
    }
    return self;
}

@end
