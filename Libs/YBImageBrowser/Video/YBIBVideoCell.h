//
//  YBIBVideoCell.h
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/7/10.
//  Copyright © 2019 杨波. All rights reserved.
//

#import "YBIBCellProtocol.h"
#import "YBIBScreenRotationHandler.h"

NS_ASSUME_NONNULL_BEGIN
@protocol YBIBVideoCellDelegate <NSObject>

- (void)yb_videoViewDidClickedFullScreen:(BOOL)isFullScreen;

@end

@interface YBIBVideoCell : UICollectionViewCell <YBIBCellProtocol>

@property (nonatomic, assign) id <YBIBVideoCellDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
