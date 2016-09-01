//
//  ViewController.m
//  TaobaoDetialDemo
//
//  Created by 倪辉辉 on 16/9/1.
//  Copyright © 2016年 倪辉辉. All rights reserved.
//

#import "ViewController.h"
#define WIDTH    [UIScreen mainScreen].bounds.size.width
#define HEIGHT    [UIScreen mainScreen].bounds.size.height




@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UIWebViewDelegate>
{
    CGFloat _maxContentOffSet_Y;
    NSMutableArray *_dataArray;
}
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)UIWebView *webView;
@property(nonatomic,strong)UILabel *headLab;
@property(nonatomic,strong)UIView *contentView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _maxContentOffSet_Y = 60;
    _dataArray = [NSMutableArray arrayWithObjects:@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"", nil];
    [self loadContentView];
}

- (void)loadContentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:self.view.frame];
        [self.view addSubview:_contentView];
    }
    
    // first view
    [self.contentView addSubview:self.tableView];
    
    // second view
    [self.contentView addSubview:self.webView];
    
    UILabel *hv = self.headLab;
    // headLab
    [self.webView addSubview:hv];
    [self.headLab bringSubviewToFront:self.contentView];
    
    
    
    // 开始监听_webView.scrollView的偏移量
    [_webView.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}


- (UILabel *)headLab
{
    if(!_headLab){
        _headLab = [[UILabel alloc] init];
        _headLab.text = @"上拉，返回详情";
        _headLab.textAlignment = NSTextAlignmentCenter;
//        _headLab.font = FONT(13);
        
    }
    
    _headLab.frame = CGRectMake(0, 0, WIDTH, 40.f);
    _headLab.alpha = 0.f;
    _headLab.textColor = [UIColor darkGrayColor];
    
    
    return _headLab;
}


- (UITableView *)tableView
{
    if(!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, self.contentView.bounds.size.height) style:UITableViewStylePlain];
        //    _tableView.contentSize = CGSizeMake(PDWidth_mainScreen, 800);
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 40.f;
        _tableView.backgroundColor = [UIColor yellowColor];
        UILabel *tabFootLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 60)];
        tabFootLab.text = @"继续拖动，查看图文详情";
//        tabFootLab.font = FONT(13);
        tabFootLab.textAlignment = NSTextAlignmentCenter;
        //        tabFootLab.backgroundColor = PDColor_Orange;
        _tableView.tableFooterView = tabFootLab;
    }
    
    return _tableView;
}


- (UIWebView *)webView
{
    if(!_webView){
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, _tableView.contentSize.height, WIDTH, HEIGHT)];
        _webView.delegate = self;
        _webView.scrollView.delegate = self;
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]]];
    }
    
    return _webView;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if(object == _webView.scrollView && [keyPath isEqualToString:@"contentOffset"])
    {
        NSLog(@"----old:%@----new:%@",change[@"old"],change[@"new"]);
        [self headLabAnimation:[change[@"new"] CGPointValue].y];
    }else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    return cell;
}


// 头部提示文本动画
- (void)headLabAnimation:(CGFloat)offsetY
{
    _headLab.alpha = -offsetY/60;
    _headLab.center = CGPointMake(WIDTH/2, -offsetY/2.f);
    // 图标翻转，表示已超过临界值，松手就会返回上页
    if(-offsetY>_maxContentOffSet_Y){
        _headLab.textColor = [UIColor redColor];
        _headLab.text = @"释放，返回详情";
    }else{
        _headLab.textColor = [UIColor grayColor];
        _headLab.text = @"上拉，返回详情";
    }
}

#pragma mark ---- scrollView delegate

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat offsetY = scrollView.contentOffset.y;
    
    if([scrollView isKindOfClass:[UITableView class]]) // tableView界面上的滚动
    {
        // 能触发翻页的理想值:tableView整体的高度减去屏幕本省的高度
        CGFloat valueNum = _tableView.contentSize.height -HEIGHT;
        if ((offsetY - valueNum) > _maxContentOffSet_Y)
        {
            [self goToDetailAnimation]; // 进入图文详情的动画
        }
    }
    
    else // webView页面上的滚动
    {
        NSLog(@"-----webView-------");
        if(offsetY<0 && -offsetY>_maxContentOffSet_Y)
        {
            [self backToFirstPageAnimation]; // 返回基本详情界面的动画
        }
    }
}


// 进入详情的动画
- (void)goToDetailAnimation
{
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        _webView.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        _tableView.frame = CGRectMake(0, -self.contentView.bounds.size.height, WIDTH, self.contentView.bounds.size.height);
    } completion:^(BOOL finished) {
        
    }];
}


// 返回第一个界面的动画
- (void)backToFirstPageAnimation
{
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        _tableView.frame = CGRectMake(0, 0, WIDTH, self.contentView.bounds.size.height);
        _webView.frame = CGRectMake(0, _tableView.contentSize.height, WIDTH, HEIGHT);
        
    } completion:^(BOOL finished) {
        
    }];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
