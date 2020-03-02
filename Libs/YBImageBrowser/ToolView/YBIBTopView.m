//
//  YBIBTopView.m
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/7/6.
//  Copyright © 2019 杨波. All rights reserved.
//

#import "YBIBTopView.h"

@interface YBIBTopView ()
@property (nonatomic, strong) UILabel *pageLabel;
@end

@implementation YBIBTopView

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.pageLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat height = 20, width = 60;
    self.pageLabel.frame = CGRectMake((self.bounds.size.width-width)/2., (self.bounds.size.height-height)/2.,
                                      width , height);
}

#pragma mark - public

+ (CGFloat)defaultHeight {
    return 30;
}

- (void)setPage:(NSInteger)page totalPage:(NSInteger)totalPage {
    if (totalPage <= 1) {
        self.pageLabel.hidden = YES;
    } else {
        self.pageLabel.hidden  = NO;
        
        NSString *text = [NSString stringWithFormat:@"%ld | %ld", page + (NSInteger)1, totalPage];
        NSShadow *shadow = [NSShadow new];
        shadow.shadowBlurRadius = 4;
        shadow.shadowOffset = CGSizeMake(0, 1);
        shadow.shadowColor = UIColor.darkGrayColor;
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSShadowAttributeName:shadow}];
        self.pageLabel.attributedText = attr;
    }
}

#pragma mark - getters & setters

- (UILabel *)pageLabel {
    if (!_pageLabel) {
        _pageLabel = [UILabel new];
        _pageLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.25];
        _pageLabel.layer.cornerRadius = 10;
        _pageLabel.layer.masksToBounds = YES;
        _pageLabel.textAlignment = NSTextAlignmentCenter;
        _pageLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _pageLabel;
}
@end
