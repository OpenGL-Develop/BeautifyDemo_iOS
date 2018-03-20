//
//  MGFilterView.m
//  FaceppDemo
//
//  Created by Li Bo on 2017/3/22.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "MGBottomItemView.h"
#import <MGBaseKit/MGBaseKit.h>
#import "MGItemCell.h"

@interface MGBottomItemView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, assign) UICollectionViewScrollDirection viewDirection;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) MGBeautyModel *models;

@end

@implementation MGBottomItemView

- (instancetype)initWithFrame:(CGRect)frame Models:(MGBeautyModel*)models direction:(UICollectionViewScrollDirection)direction
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = MGColorWithRGB(1, 1, 1, 0.5);
        self.models = models;
        self.viewDirection = direction;
        
        [self addSubview:self.collectionView];
    }
    return self;
}

- (UICollectionView *)collectionView{
    if (_collectionView == nil) {
        CGFloat cellWidth = (CGRectGetWidth(self.bounds)-50)/5.0;
        if (self.viewDirection == UICollectionViewScrollDirectionHorizontal) {
            cellWidth = (CGRectGetWidth(self.bounds)-30)/5.0;;
        }
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = self.viewDirection;
        flowLayout.minimumLineSpacing = 5;
        flowLayout.minimumInteritemSpacing = 5;
        flowLayout.itemSize = CGSizeMake(cellWidth, cellWidth);
        flowLayout.sectionInset = UIEdgeInsetsMake(15, 10, 0, 10);
        
        if (self.viewDirection == UICollectionViewScrollDirectionHorizontal) {
            flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
        }
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds
                                             collectionViewLayout:flowLayout];
        [_collectionView setBackgroundColor:[UIColor clearColor]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        [_collectionView registerNib:[UINib nibWithNibName:@"MGItemCell" bundle:nil]
          forCellWithReuseIdentifier:NSStringFromClass([MGItemModel class])];
    }
    return _collectionView;
}

- (void)reloadCellWithIndex:(NSIndexPath *)indexPath{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (indexPath.row < self.models.dataArray.count) {
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        }
    });
}
- (void)reloadAll{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

#pragma mark - UICollectionViewDataSource -
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.models.dataArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    BaseModel *model = [self getModelWithIndex:indexPath];
    BaseCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([model class])
                                                                         forIndexPath:indexPath];
    [model setIndexPath:indexPath];
    [cell setDateModel:model];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate -
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:self.models.value1 inSection:0];
  
    /** 重复点击 */
    if (indexPath.row == tempIndexPath.row) {
        return;
    }
    /**   */
    MGItemModel *itemModel = [self getModelWithIndex:indexPath];
    [itemModel setSelected:YES];
    
        switch (itemModel.status) {
            case DownNot:
            case DownError:
            case Downing:
            {
                [itemModel setSelected:NO];

                if (self.delegate) {
                    [self.delegate MGBottomBarSelected:itemModel];
                }

                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }
                break;
            default:
            {
                BaseModel *oldModel = [self getModelWithIndex:tempIndexPath];
                [oldModel setSelected:NO];
                [collectionView reloadData];
                
                self.models.value1 = indexPath.row;
                BaseModel *model = self.models.dataArray[indexPath.row];
                if (self.delegate) {
                    [self.delegate MGBottomBarSelected:model];
                }
            }
                break;
        }
}

#pragma mark - UICollectionViewDelegateFlowLayout -
- (MGItemModel *)getModelWithIndex:(NSIndexPath *)indexPath{
    MGItemModel *tempModel = self.models.dataArray[indexPath.row];
    return tempModel;
}

@end
