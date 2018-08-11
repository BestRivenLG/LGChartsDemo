//
//  ViewController.m
//  LGChartsDemo
//
//  Created by liangang zhan on 2018/7/30.
//  Copyright © 2018年 liangang zhan. All rights reserved.
//

#import "ViewController.h"
#import "PNChart.h"
#import "WWBarView.h"
#import "LCChartView.h"
#import "LGTodayStateModel.h"
#import "MJExtension.h"
#define RandomColor [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1]
@interface ViewController ()<PNChartDelegate>
@property (nonatomic) PNBarChart * barChart;
@property (nonatomic,strong) UIView * bgView;
@property (nonatomic,strong) UIView *bgView2;
@property (strong, nonatomic) LCChartView *chartViewLine;
@property (nonatomic,copy)NSArray *dataArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
//    [self initUI];
    [self initUI3];
//    [self initUI2];

}
-(NSArray *)dataArr{
    if (_dataArr == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"timeData.plist" ofType:nil];
        NSArray *arr = [NSArray arrayWithContentsOfFile:path];
        _dataArr = [NSArray arrayWithArray:[LGTodayStateModel mj_objectArrayWithKeyValuesArray:arr]];
    }
    return _dataArr;
}

- (IBAction)clickAction1:(id)sender {
    [self showData];
}

- (IBAction)clickAction2:(id)sender {
    [self showData2];
}


- (void)showData2{

    LCChartViewModel *model = [LCChartViewModel modelWithColor:[UIColor redColor] plots:[self randomArrayWithCount:24] project:@"1组"];
    LCChartViewModel *model1 = [LCChartViewModel modelWithColor:RandomColor plots:[self randomArrayWithCount:24] project:@"2组"];
    LCChartViewModel *model2 = [LCChartViewModel modelWithColor:RandomColor plots:[self randomArrayWithCount:24] project:@"3组"];
    LCChartViewModel *model3 = [LCChartViewModel modelWithColor:RandomColor plots:[self randomArrayWithCount:24] project:@"4组"];
    LCChartViewModel *model4 = [LCChartViewModel modelWithColor:RandomColor plots:[self randomArrayWithCount:24] project:@"5组"];
    
    _chartViewLine.xAxisTitleArray = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8" , @"9", @"10", @"11", @"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24"];//@[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8" , @"9", @"10", @"11", @"12"]
    [self.chartViewLine showChartViewWithYAxisMaxValue:180 dataSource:@[model,model1,model2,model3,model4] danwei:@"(单位/min)"];
}

- (void)showData{
   
    _chartViewLine.xAxisTitleArray = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8" , @"9", @"10", @"11", @"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24"];
    
    LCChartViewModel *model = [LCChartViewModel modelWithColor:[UIColor redColor] plotsModelArr:self.dataArr project:@"1组"];
    
    NSMutableArray *arr = [self.dataArr mutableArrayValueForKeyPath:@"sit_time"];
    CGFloat maxValue = [[arr valueForKeyPath:@"@max.floatValue"] floatValue];
    
    [self.chartViewLine showOtherChartViewWithYAxisMaxValue:maxValue dataSource:@[model] danwei:@"(单位/min)"];
    
}

- (NSArray *)randomArrayWithCount:(NSInteger)dataCounts {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < dataCounts; i++) {
        NSString *number = [NSString stringWithFormat:@"%d",arc4random_uniform(181)];
        [array addObject:number];
    }
    return array.copy;
}

-(void)initUI3
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 150, size.width, 300)];
//    bgView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:bgView];
    self.bgView = bgView;
    
    _chartViewLine = [LCChartView chartViewWithType:LCChartViewTypeBar];
    _chartViewLine.frame = CGRectMake(0, 0, size.width, 300);
    _chartViewLine.backColor = [UIColor colorWithRed:31/255.0 green:31/255.0 blue:32/255.0 alpha:1.0];
    [self.bgView addSubview:_chartViewLine];
}

-(void)initUI2 {
    CGSize size = [UIScreen mainScreen].bounds.size;
    UIView *bgView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 80+300+10, size.width, 300)];
    bgView2.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:bgView2];
    self.bgView2 = bgView2;
    [self unEnableScrollWithCustomXAxisValue];
}

- (void)unEnableScrollWithCustomXAxisValue
{
    WWBarView *barView = [[WWBarView alloc] initWithFrame:CGRectMake(10, 0, self.view.bounds.size.width-10, 300)];
    
    [self.bgView2 addSubview:barView];
    barView.highlightLineShowEnabled = YES;
    barView.zoomEnabled = NO;
    barView.strokeColor = [UIColor redColor];
    barView.yMAxValue = 180;
    barView.yMinValue = 0;
    barView.yisYLabelArray =@[@"296",
                              @"198",
                              @"100",
                              @"2"];
    barView.horizontalLinePitch = (barView.frame.size.height - barView.topSeparationDistance - barView.bottomSeparationDistance)/3;
    
    barView.horizontalLineCount =4;
    
    barView.PromptLabel.text = @"无完成的FOREX模拟挑战赛";
    
    barView.chartItemColor.strokeTopColor = [UIColor redColor];
    barView.yisYLeftLabelArray = @[];
    
    CGFloat distance = (barView.frame.size.width-(barView.leftSeparationDistance + barView.rightSeparationDistance))/24.0;
    barView.horizontalSpacing = distance/2;
    barView.candleWidth = distance/2;
    barView.dateArray = @[];
    barView.autoDisplayXAxis = YES;
    NSArray *times = @[];//@[@"7:00",@"14:00",@"21:00"];
    NSMutableArray *frames = @[].mutableCopy;
    barView.xAxisCount = 24;
    barView.drawYAxisEnable = YES;
    barView.rightYAxisColor = [UIColor lightTextColor];
    
    barView.animation = YES;
    CGFloat width = (barView.frame.size.width - barView.leftSeparationDistance - barView.rightSeparationDistance);
    NSMutableArray *xAxiscoordinateArray = @[].mutableCopy;
    for (int i =0; i<times.count; i++) {
        //竖直线条
        CGFloat pitch =  width/(24.0);
        CGFloat firstLineStartX = pitch *7*(i+1);
        CGFloat lineStartX = pitch *7+ pitch *7*(i);
        CGRect rect;
        
        if (i == 0){
            
            rect = CGRectMake(firstLineStartX + barView.candleWidth/2 + barView.horizontalSpacing/2 , 2, 24, 24);
            [frames addObject:[NSValue valueWithCGRect:rect]];
            
            
        }else{
            
            rect = CGRectMake(lineStartX+barView.candleWidth/2+ barView.horizontalSpacing/2  , 2, 24, 24);
            
            [frames addObject:[NSValue valueWithCGRect:rect]];
            
        }
        WWBarXAxisItem *item = [WWBarXAxisItem itemModelWithCoordinateAxisX:times[i] rect:rect];
        [xAxiscoordinateArray addObject:item];
    }
    
    barView.lineDataArray = @[].mutableCopy;
    barView.xAxiscoordinateArray = xAxiscoordinateArray;
    
    barView.dataArray = @[@161,
                          @72,
                          @31,
                          @4,
                          @3,
                          @5,
                          @2,
                          @14,
                          @16,
                          @33,
                          @46,
                          @21,
                          @14,
                          @26,
                          @26,
                          @56,
                          @99,
                          @72,
                          @75,
                          @101,
                          @160,
                          @190,
                          @246,
                          @189];
    
    [barView stroke];
    
    
}

-(void)initUI {
    CGSize size = [UIScreen mainScreen].bounds.size;
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 80, size.width, 300)];
    bgView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:bgView];
    self.bgView = bgView;
    
    static NSNumberFormatter *barChartFormatter;
    if (!barChartFormatter) {
        barChartFormatter = [[NSNumberFormatter alloc] init];
        barChartFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
        barChartFormatter.allowsFloats = NO;
        barChartFormatter.maximumFractionDigits = 0;
    }
    self.barChart = [[PNBarChart alloc] initWithFrame:CGRectMake(0, 135.0, SCREEN_WIDTH, 200.0)];
//    self.barChart.showLabel = NO;
    self.barChart.yLabelFormatter = ^(CGFloat yValue) {
        return [barChartFormatter stringFromNumber:@(yValue)];
    };
    
    self.barChart.yChartLabelWidth = 20.0;
    self.barChart.chartMarginLeft = 30.0;
    self.barChart.chartMarginRight = 10.0;
    self.barChart.chartMarginTop = 5.0;
    self.barChart.chartMarginBottom = 10.0;
    
    
    self.barChart.labelMarginTop = 5.0;
    self.barChart.showChartBorder = YES;
    [self.barChart setXLabels:@[@"2", @"3", @"4", @"5", @"2", @"3", @"4", @"5", @"2", @"3", @"4", @"5"]];
    //       self.barChart.yLabels = @[@-10,@0,@10];
    //        [self.barChart setYValues:@[@10000.0,@30000.0,@10000.0,@100000.0,@500000.0,@1000000.0,@1150000.0,@2150000.0]];
    [self.barChart setYValues:@[@10.82, @1.88, @6.96, @33.93, @10.82, @1.88, @6.96, @33.93,@10.82,@10.82,@10.82,@10.82]];
    [self.barChart setStrokeColors:@[PNGreen, PNGreen, PNRed, PNGreen, PNGreen, PNGreen, PNRed, PNGreen, PNGreen, PNGreen, PNRed, PNGreen]];
    self.barChart.isGradientShow = NO;
    self.barChart.isShowNumbers = YES;
    self.barChart.yMinValue =0;
    self.barChart.yMaxValue = 40;
    [self.barChart strokeChart];
    
    self.barChart.delegate = self;
    
    [self.view addSubview:self.barChart];
    
}

- (void)userClickedOnBarAtIndex:(NSInteger)barIndex {
    
    NSLog(@"Click on bar %@", @(barIndex));
    
    PNBar *bar = self.barChart.bars[(NSUInteger) barIndex];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    animation.fromValue = @1.0;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.toValue = @1.1;
    animation.duration = 0.2;
    animation.repeatCount = 0;
    animation.autoreverses = YES;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    
    [bar.layer addAnimation:animation forKey:@"Float"];
}

@end
