//
//  SYViewController.m
//  SYCollectionMove
//
//  Created by 666gps on 2017/12/27.
//  Copyright © 2017年 666gps. All rights reserved.
//

#import "SYViewController.h"
#import "SYCollectionViewCell.h"

#define WindowWidth [UIScreen mainScreen].bounds.size.width
#define WindowHeight [UIScreen mainScreen].bounds.size.height

@interface SYViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    UILongPressGestureRecognizer * cellPress;
}
@property (nonatomic,strong) NSMutableArray * dataArray;
@property (nonatomic,strong) UICollectionView * collectionView;


@end

@implementation SYViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [[NSMutableArray alloc]init];
    for (int i = 0; i < 10; i++) {
        [self.dataArray addObject:[NSString stringWithFormat:@"第%d个",i]];
    }
    [self creatBaseUI];
}
-(void)creatBaseUI{
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    layout.itemSize = CGSizeMake((WindowWidth - 50) / 4, 80);
    
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, WindowWidth, WindowHeight) collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([SYCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([SYCollectionViewCell class])];
    cellPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(cellMoveingAction:)];
    [self.collectionView addGestureRecognizer:cellPress];
    [self.view addSubview:self.collectionView];
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SYCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SYCollectionViewCell class]) forIndexPath:indexPath];
    cell.disButton.hidden = YES;
    cell.titleLabel.text = self.dataArray[indexPath.row];
    
    return cell;
}
#pragma mark - cell长按抖动
-(void)cellMoveingAction:(UILongPressGestureRecognizer *)sender{
    NSIndexPath * index = [self.collectionView indexPathForItemAtPoint:[sender locationInView:self.collectionView]];
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            //开始在特定的索引路径上对cell（单元）进行Interactive Movement（交互式移动工作
            [self.collectionView beginInteractiveMovementForItemAtIndexPath:index];
            [self beginMove];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            //在手势作用期间更新交互移动的目标位置。
            [self.collectionView updateInteractiveMovementTargetPosition:[sender locationInView:self.collectionView]];
            [self beginMove];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            //在完成手势动作后，结束交互式移动
            [self.collectionView endInteractiveMovement];
            [self endMove];
            [self.collectionView reloadData];
        }
            break;
        default:
        {
            //取消Interactive Movement。
            [self.collectionView endInteractiveMovement];
        }
            break;
    }
   
}
#pragma mark - 处理抖动动画
-(void)beginMove{
    for (SYCollectionViewCell * cell in [self.collectionView visibleCells]) {
        cell.disButton.hidden = NO;
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAutoreverse animations:^{
            cell.transform = CGAffineTransformMakeRotation(0.05);
        } completion:nil];
    }
}
-(void)endMove{
    for (SYCollectionViewCell * cell in [self.collectionView visibleCells]) {
        cell.disButton.hidden = YES;
        [cell.layer removeAllAnimations];
    }
}
-(void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
//这里不使用下面的语句是因为下面的语句是交换两个数据源的位置
//    [self.dataArray exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    
    //使用下面的方式，使动画看起来更流畅，先移除要移动的数据，然后在要放置的位置插入数据
    NSString * sourceStr = self.dataArray[sourceIndexPath.row];
    [self.dataArray removeObject:self.dataArray[sourceIndexPath.row]];
    [self.dataArray insertObject:sourceStr atIndex:destinationIndexPath.row];
    [self.collectionView reloadData];
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //因为添加了删除操作，这里才需要当用户再次点击cell的时候，取消动画和删除按钮
    
    [self endMove];
    [self.collectionView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
