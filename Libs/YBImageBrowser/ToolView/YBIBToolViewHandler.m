//
//  YBIBToolViewHandler.m
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/7/7.
//  Copyright © 2019 杨波. All rights reserved.
//

#import "YBIBToolViewHandler.h"
#import "YBIBCopywriter.h"
#import "YBIBUtilities.h"
#import "YBIBVideoActionBar.h"

@interface YBIBToolViewHandler ()
@property (nonatomic, strong) YBIBTopView *topView;
@end

@implementation YBIBToolViewHandler

#pragma mark - <YBIBToolViewHandler>

@synthesize yb_containerView = _yb_containerView;
@synthesize yb_containerSize = _yb_containerSize;
@synthesize yb_currentPage = _yb_currentPage;
@synthesize yb_totalPage = _yb_totalPage;
@synthesize yb_currentOrientation = _yb_currentOrientation;
@synthesize yb_currentData = _yb_currentData;

- (void)yb_containerViewIsReadied {
    [self.yb_containerView addSubview:self.topView];
    [self layoutWithExpectOrientation:self.yb_currentOrientation()];
}

- (void)yb_pageChanged {
    [self.topView setPage:self.yb_currentPage() totalPage:self.yb_totalPage()];
}

- (void)yb_hide:(BOOL)hide {
    self.topView.hidden = hide;
}

- (void)yb_orientationWillChangeWithExpectOrientation:(UIDeviceOrientation)orientation {
}

- (void)yb_orientationChangeAnimationWithExpectOrientation:(UIDeviceOrientation)orientation {
    [self layoutWithExpectOrientation:orientation];
}

#pragma mark - private

- (BOOL)currentDataShouldHideSaveButton {
    id<YBIBDataProtocol> data = self.yb_currentData();
    BOOL allow = [data respondsToSelector:@selector(yb_allowSaveToPhotoAlbum)] && [data yb_allowSaveToPhotoAlbum];
    BOOL can = [data respondsToSelector:@selector(yb_saveToPhotoAlbum)];
    return !(allow && can);
}

- (void)layoutWithExpectOrientation:(UIDeviceOrientation)orientation {
    CGSize containerSize = self.yb_containerSize(orientation);
    UIEdgeInsets padding = YBIBPaddingByBrowserOrientation(orientation);
   
    self.topView.hidden = [YBIBUtilities sharedInstance].bFullScreen ? YES:NO;
    self.topView.frame = CGRectMake(padding.left, containerSize.height-[YBIBTopView defaultHeight]-padding.bottom-[YBIBVideoActionBar defaultHeight],
                                    containerSize.width - padding.left - padding.right, [YBIBTopView defaultHeight]);
}

#pragma mark - getters
- (YBIBTopView *)topView {
    if (!_topView) {
        _topView = [YBIBTopView new];
    }
    return _topView;
}

@end
