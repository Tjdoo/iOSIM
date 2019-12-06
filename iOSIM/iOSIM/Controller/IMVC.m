//
//  IMVC.m
//  iOSIM
//
//  Created by CYKJ on 2019/11/12.
//  Copyright © 2019年 D. All rights reserved.


#import "IMVC.h"
#import "IMInputBottomCVCell.h"
#import "VoiceView.h"
#import "Macros.h"
#import "UIView+Layout.h"


#define  INPUT_BOTTOM_ITEM_COUNT   4

@interface IMVC () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView * listTableView;
@property (weak, nonatomic) IBOutlet UITextField * inputTextField;
@property (weak, nonatomic) IBOutlet UICollectionView * inputBottomCV;
@property (weak, nonatomic) IBOutlet UIView * voiceBgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * voiceBgViewBottomConstraint;
@property (weak, nonatomic) VoiceView * voiceView;

@property (nonatomic, copy) NSArray * inputBottomCVData;

@end


@implementation IMVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.listTableView.tableFooterView = [UIView new];
    
    [self voiceView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    UIViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SocketVC_SBID"];
//    [self presentViewController:vc animated:YES completion:nil];
}


#pragma mark - UITableViewDelegate/DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0;
}


#pragma mark - UICollectionViewDelegate/DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return INPUT_BOTTOM_ITEM_COUNT;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    IMInputBottomCVCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:IM_INPUT_BOTTOM_CVCELL_RUID forIndexPath:indexPath];
    
    cell.iconImageView.image = self.inputBottomCVData[indexPath.item];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((SCREEN_WIDTH - 20) / INPUT_BOTTOM_ITEM_COUNT, collectionView.height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            CGFloat targetConstant = 0;
            [UIView animateWithDuration:0.25 animations:^{
                self.voiceBgViewBottomConstraint.constant = targetConstant;
                [self.view layoutIfNeeded];
            }];
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - GET
/**
  *  @brief   输入框底部的入口图片数组
  */
- (NSArray *)inputBottomCVData
{
    if (_inputBottomCVData == nil) {
        // 数组元素个数  = INPUT_BOTTOM_ITEM_COUNT
        _inputBottomCVData = @[ [UIImage imageNamed:@"语音"],
                                [UIImage imageNamed:@"照片"],
                                [UIImage imageNamed:@"拍照"],
                                [UIImage imageNamed:@"服务"] ];
    }
    return _inputBottomCVData;
}

- (VoiceView *)voiceView
{
    if (_voiceView == nil) {
        VoiceView * voiceView = [[VoiceView alloc] initWithFrame:self.voiceBgView.bounds];
        [self.voiceBgView addSubview:voiceView];
        _voiceView = voiceView;
    }
    return _voiceView;
}

@end
