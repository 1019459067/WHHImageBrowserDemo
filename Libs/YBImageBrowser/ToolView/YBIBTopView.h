//
//  YBIBTopView.h
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/7/6.
//  Copyright © 2019 杨波. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YBIBTopView : UIView

/// 页码标签
@property (nonatomic, strong, readonly) UILabel *pageLabel;

/**
 设置页码

 @param page 当前页码
 @param totalPage 总页码数
 */
- (void)setPage:(NSInteger)page totalPage:(NSInteger)totalPage;

+ (CGFloat)defaultHeight;

@end

NS_ASSUME_NONNULL_END
