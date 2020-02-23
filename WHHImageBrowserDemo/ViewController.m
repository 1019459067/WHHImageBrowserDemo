//
//  ViewController.m
//  WHHImageBrowserDemo
//
//  Created by XWH on 2020/2/21.
//  Copyright © 2020 XWH. All rights reserved.
//

#import "ViewController.h"
#import "BaseListCell.h"
#import "YBIBUtilities.h"
#import "YBImageBrowser.h"
#import "YBIBVideoData.h"

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, copy) NSArray *dataArray;

@end

@implementation ViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.collectionView];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - public

- (id)viewAtIndex:(NSInteger)index {
    BaseListCell *cell = (BaseListCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    return cell ? cell.contentImgView : nil;
}

#pragma mark - <UICollectionViewDataSource, UICollectionViewDelegate>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BaseListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(BaseListCell.self) forIndexPath:indexPath];
    cell.data = self.dataArray[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self selectedIndex:indexPath.row];
}


#pragma mark - getter
- (NSArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
        NSMutableArray *array = [NSMutableArray array];
        // imageURLs
        [array addObjectsFromArray:[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ImageURLs" ofType:@"plist"]]];
        // imageNames
        [array addObjectsFromArray:@[@"localImage1.gif", @"localImage0.jpg", @"localBigImage0.jpeg"]];
        // videos
        [array addObjectsFromArray:@[@"localVideo0.mp4", @"https://aweme.snssdk.com/aweme/v1/playwm/?video_id=v0200ff00000bdkpfpdd2r6fb5kf6m50&line=0.mp4"]];
        self.dataArray = array;
        [self.collectionView reloadData];
    }
    return _dataArray;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGFloat padding = 5, cellLength = ([UIScreen mainScreen].bounds.size.width - padding * 2) / 3;
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize = CGSizeMake(cellLength, cellLength);
        layout.sectionInset = UIEdgeInsetsMake(padding, padding, padding, padding);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - YBIBStatusbarHeight() - 40 - YBIBSafeAreaBottomHeight() - 44) collectionViewLayout:layout];
        [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass(BaseListCell.self) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass(BaseListCell.self)];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}


- (void)selectedIndex:(NSInteger)index {
    
    NSMutableArray *datas = [NSMutableArray array];
    [self.dataArray enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj hasSuffix:@".mp4"] && [obj hasPrefix:@"http"]) {
            
            // 网络视频
            YBIBVideoData *data = [YBIBVideoData new];
            data.videoURL = [NSURL URLWithString:obj];
//            data.projectiveView = [self viewAtIndex:idx];
            [datas addObject:data];
         
        } else if ([obj hasSuffix:@".mp4"]) {
            
            // 本地视频
            NSString *path = [[NSBundle mainBundle] pathForResource:obj.stringByDeletingPathExtension ofType:obj.pathExtension];
            YBIBVideoData *data = [YBIBVideoData new];
            data.videoURL = [NSURL fileURLWithPath:path];
            data.projectiveView = [self viewAtIndex:idx];
            [datas addObject:data];
            
        } else if ([obj hasPrefix:@"http"]) {
            
            // 网络图片
            YBIBImageData *data = [YBIBImageData new];
            data.imageURL = [NSURL URLWithString:obj];
            data.projectiveView = [self viewAtIndex:idx];
            [datas addObject:data];
            
        } else {
            
            // 本地图片
            YBIBImageData *data = [YBIBImageData new];
            data.imageName = obj;
            data.projectiveView = [self viewAtIndex:idx];
            [datas addObject:data];
            
        }
    }];
    
//    YBImageBrowser *browser = [[YBImageBrowser alloc]init];
//    browser.dataSourceArray = datas;
//    browser.currentPage = index;
//    [browser show];
    
    YBImageBrowser *browser = [[YBImageBrowser alloc]initWithDataSoure:datas index:index delegate:self];
//      browser.dataSourceArray = datas;
//      browser.currentPage = index;
      [browser show];
}

@end
