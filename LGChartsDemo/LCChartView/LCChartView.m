//
//  LCChartView.m
//  LCProject
//
//  Created by liangrongchang on 2017/1/6.
//  Copyright © 2017年 Rochang. All rights reserved.
//

#import "LCChartView.h"
#import "UIView+LCLayout.h"
#import "LCMethod.h"
#import "LGTodayStateModel.h"

static NSTimeInterval duration = 0.8;
static CGFloat yAxisMaxY = 0;
static CGFloat yTextCenterMargin = 0;
/** 显示数据的区域高度 */
static CGFloat dataChartHeight = 0;
static CGFloat axisLabelHieght = 0;
static CGFloat xAxisMaxX = 0;
static CGFloat noteViewRowH = 15;

@interface LCChartView ()<UIScrollViewDelegate, CAAnimationDelegate>
// UI
@property (strong, nonatomic) NSMutableArray <UILabel *>*yAxisLabels;
@property (strong, nonatomic) NSMutableArray <UILabel *>*xAxisLabels;
@property (strong, nonatomic) NSMutableArray <UIView *>*allSubView;
@property (strong, nonatomic) UIScrollView *noteView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UILabel *yAxisLabel;
@property (strong, nonatomic) UILabel *xAxisLabel;

// 数据
@property (assign, nonatomic) CGFloat yAxisMaxValue;
@property (strong, nonatomic) NSArray<LCChartViewModel *> *dataSource;

@property (strong, nonatomic) NSArray<LCChartViewModel *> *dataOtherSource;

@property (assign, nonatomic) BOOL isLianxu;
//捏合时 记录放大缩小bar的宽度间距变量属性记录
@property (assign, nonatomic) CGFloat midBarWidth;
@property (assign, nonatomic) CGFloat originBarWidth;
@property (assign, nonatomic) CGFloat midBarMargin;
@property (assign, nonatomic) CGFloat originBarMargin;

/** 捏合时记录原先X轴点距离 */
@property (assign, nonatomic) CGFloat orginXAxisMargin;
/** 捏合时记录原先动画flag */
@property (assign, nonatomic) BOOL orginAnimation;
/** X轴箭头离XAxisLabel距离 */
@property (assign, nonatomic) CGFloat xArrowsToText;
@property (assign, nonatomic) CGPoint originPoint;
/** 第一次动画 */
@property (strong, nonatomic) NSMutableArray <CAShapeLayer *>*firstLayers;
/** 第二次动画 */
@property (strong, nonatomic) NSMutableArray <CAShapeLayer *>*scondLayers;
@property (strong, nonatomic) NSMutableArray *textLayers;
// response
@property (strong, nonatomic) UITapGestureRecognizer *twoTap;
@property (strong, nonatomic) UIPinchGestureRecognizer *pinch;

@end

@implementation LCChartView

#pragma mark - API
+ (instancetype)chartViewWithType:(LCChartViewType)type {
    LCChartView *axisView = [[LCChartView alloc] init];
    axisView.chartViewType = type;
    return axisView;
}

- (instancetype)initWithFrame:(CGRect)frame chartViewType:(LCChartViewType)type {
    if (self = [super initWithFrame:frame]) {
        [self initData];
        self.chartViewType = type;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initData];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initData];
    }
    return self;
}

- (void)showChartViewWithYAxisMaxValue:(CGFloat)yAxisMaxValue dataSource:(NSArray<LCChartViewModel *> *)dataSource {
    _yAxisMaxValue = yAxisMaxValue;
    self.dataSource = dataSource;
    _barWidth = _originBarWidth = _midBarWidth = 15;
    _isLianxu = NO;
    [self showChartView];
}

- (void)showChartViewWithYAxisMaxValue:(CGFloat)yAxisMaxValue dataSource:(NSArray<LCChartViewModel *> *)dataSource danwei:(NSString *)danwei{
    _yAxisMaxValue = yAxisMaxValue;
    self.dataSource = dataSource;
    self.labelDWString = danwei;
    _yTextToAxis = _yAxisCount = _plotsButtonWH = 5;//yAxisMaxValue;///2;//
//    if (yAxisMaxValue>16) {
//        _yTextToAxis = _yAxisCount = _plotsButtonWH = yAxisMaxValue/2;//5;
//    }
//    _barWidth = 15;
    _barWidth = _originBarWidth = _midBarWidth = 15;

    _barMargin = 20;
    _xAxisTextMargin = _orginXAxisMargin = _xArrowsToText = 30;
    _isLianxu = NO;
    [self showChartView];
}

- (void)showOtherChartViewWithYAxisMaxValue:(CGFloat)yAxisMaxValue dataSource:(NSArray<LCChartViewModel *> *)dataSource danwei:(NSString *)danwei{
    _yAxisMaxValue = yAxisMaxValue;
    self.dataOtherSource = dataSource;
    self.labelDWString = danwei;
    _yTextToAxis = _yAxisCount = _plotsButtonWH = 6;//5;
    _barWidth = _originBarWidth = _midBarWidth = 18;
    _barMargin = _originBarMargin = _midBarMargin = 0;
    _xAxisTextMargin = _orginXAxisMargin = _xArrowsToText = 0;
    _isLianxu = YES;
    [self showOtherChartView];
}



#pragma mark - private method
- (void)initData {
    _axisColor = [UIColor colorWithRed:157/255.0 green:158/255.0 blue:160/255.0 alpha:1.0];//[UIColor darkGrayColor];
    _backColor = [UIColor clearColor];
    _axisTitleSizeFont = 10;
    _plotsLabelSelectedColor = _plotsButtonSelectedColor = _plotsLabelColor = [UIColor redColor];
    _yTextColor = _xTextColor = _plotsButtonColor = _lineChartFillViewColor = [UIColor colorWithRed:157/255.0 green:158/255.0 blue:160/255.0 alpha:1.0];//[UIColor darkGrayColor];
    _barWidth = 15;
    _yAxisMaxValue = 1000;
    _chartViewType = LCChartViewTypeLine;
    _axisFontSize = 12;
    _plotsLabelFontSize = 9;
    _barMargin = 0;//20;
    _yAxisToLeft = _chartViewRightMargin = _topMargin = 35;
    _displayPlotToLabel = 3;
    _axisWidth = _lineChartWidth = 1;
    _xAxisTextMargin = _orginXAxisMargin = _xArrowsToText = 30;
    _yTextToAxis = _yAxisCount = _plotsButtonWH = 6;//5;
    _yAxisTitle = @"";//@"y";
    _xAxisTitle = @"";//@"x";
//    if (_xAxisTitleArray.count==0) {
//       _xAxisTitleArray = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8" , @"9", @"10", @"11", @"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24"];//@[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8" , @"9", @"10", @"11", @"12"]
//    }
    _lineChartFillView = _showPlotsLabel = NO;
    _showAnimation = _orginAnimation = _showGridding = _showNote = YES;

}

- (void)showChartView {
//    _barWidth = 15;
//    _barMargin = 20;
//    _xAxisTextMargin = _orginXAxisMargin = _xArrowsToText = 30;

    if (self.dataSource.count == 0) {
        NSLog(@"请设置展示的点数据");
        return;
    };
    if (self.chartViewType == LCChartViewTypeBar && _xAxisTextMargin < _barWidth * self.dataSource.count + self.barMargin) {
        _xAxisTextMargin = self.orginXAxisMargin = _barWidth * self.dataSource.count + self.barMargin;
    }
    
    // 截取数据
    for (LCChartViewModel *model in self.dataSource) {
        if (model.plots.count > self.xAxisTitleArray.count) {
            NSLog(@"展示的点数据比X轴默认的点多,请设置xAxisTitleArray");
            model.plots = [model.plots subarrayWithRange:NSMakeRange(0, self.xAxisTitleArray.count)];
        }
    }
    [self resetDataSource];
    [self drawYAxis];
    [self drawXAxis];
    [self drawTilte];
//    [self drawYSeparators];
    if (self.chartViewType == LCChartViewTypeLine) {
        [self drawXSeparators];
        [self drawLineChartViewPots];
        [self drawLineChartViewLines];
    } else {
        [self drawBarChartViewBars];
    }
    [self drawDisplayLabels];
    [self addNote];
    [self addAnimation:self.showAnimation];
}


- (void)showOtherChartView {
//    _barWidth = 18;
//    _barMargin = 0;
//    _xAxisTextMargin = _orginXAxisMargin = _xArrowsToText = 0;

    if (self.dataOtherSource.count == 0) {
        NSLog(@"请设置展示的点数据");
        return;
    };
    if (self.chartViewType == LCChartViewTypeBar && _xAxisTextMargin < _barWidth * self.dataOtherSource.count + self.barMargin) {
        _xAxisTextMargin = self.orginXAxisMargin = _barWidth * self.dataOtherSource.count + self.barMargin;
    }
    
    // 截取数据
    for (LCChartViewModel *model in self.dataOtherSource) {
        if (model.plotsModelArr.count > self.xAxisTitleArray.count) {
            NSLog(@"展示的点数据比X轴默认的点多,请设置xAxisTitleArray");
            model.plotsModelArr = [model.plotsModelArr subarrayWithRange:NSMakeRange(0, self.xAxisTitleArray.count)];
        }
    }
    [self resetDataSource];
    [self drawYAxis];
    [self drawOtherXAxis];
    [self drawTilte];
    //    [self drawYSeparators];
    if (self.chartViewType == LCChartViewTypeLine) {
        [self drawXSeparators];
        [self drawLineChartViewPots];
        [self drawLineChartViewLines];
    } else {
//        [self drawBarChartViewBars];
        [self drawBarOtherChartViewBars];
    }
//    [self drawOtherDisplayLabels];
    [self addOtherNote];
    [self addAnimation:self.showAnimation];
}



#pragma mark - 重置数据
- (void)resetDataSource {
    for (LCChartViewModel *model in self.dataSource) {
        if (model.plotButtons) {
            [model.plotButtons removeAllObjects];
            [model.plotButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
    }
    // 移除所有的Label,CAShapeLayer
    if (self.allSubView) {
        [self.allSubView makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.allSubView removeAllObjects];
    }
    if (self.firstLayers.count) {
        [self.firstLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        [self.firstLayers removeAllObjects];
    }
    if (self.scondLayers.count) {
        [self.scondLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        [self.scondLayers removeAllObjects];
    }
    if (self.xAxisLabels.count) {
        [self.xAxisLabels makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.xAxisLabels removeAllObjects];
    }
    if (self.yAxisLabels.count) {
        [self.yAxisLabels makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.yAxisLabels removeAllObjects];
    }
    if (self.textLayers.count) {
        [self.textLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        [self.textLayers removeAllObjects];
    }
}

#pragma mark - 描绘Y轴
- (void)drawYAxis {
    for (UIView *view3 in self.subviews) {
        if (view3.tag == 120||view3.tag == 122) {
            [view3 removeFromSuperview];
        }
    }
    for (UIView *view4 in self.scrollView.subviews) {
//        if (view4.tag == 121) {
            [view4 removeFromSuperview];
//        }
    }
    
    axisLabelHieght = [LCMethod sizeWithText:@"x" fontSize:_axisFontSize].height;
    CGFloat height = [LCMethod sizeWithText:@"x" fontSize:9].height;

    // 数据展示的高度
    dataChartHeight = self.LC_height - _topMargin - _xTextToAxis - axisLabelHieght;
    
    // ylabel之间的间隙
    yTextCenterMargin = dataChartHeight / _yAxisCount;
    yAxisMaxY = MAX(_topMargin - yTextCenterMargin / 2, 0);
    CGFloat y = height+10;
    UIBezierPath *yAxisPath = [UIBezierPath bezierPath];
    _originPoint = CGPointMake(_yAxisToLeft, self.LC_height - axisLabelHieght - _xTextToAxis);//CGPointMake(_yAxisToLeft, self.LC_height - axisLabelHieght - _xTextToAxis);
    [yAxisPath moveToPoint:_originPoint];
    [yAxisPath addLineToPoint:CGPointMake(_yAxisToLeft, y)];//yAxisMaxY)];
    //画y轴箭头
//    [yAxisPath addLineToPoint:CGPointMake(_yAxisToLeft - (_axisWidth + 2), yAxisMaxY + (_axisWidth + 2))];
//    [yAxisPath moveToPoint:CGPointMake(_yAxisToLeft, yAxisMaxY)];
//    [yAxisPath addLineToPoint:CGPointMake(_yAxisToLeft + (_axisWidth + 2), yAxisMaxY + (_axisWidth + 2))];
    
    CAShapeLayer *shapeLayer = [self shapeLayerWithPath:yAxisPath lineWidth:_axisWidth fillColor:[UIColor clearColor] strokeColor:_axisColor];
    [self.layer addSublayer:shapeLayer];
    [self.firstLayers addObject:shapeLayer];
    
    // 添加Y轴Label
    for (int i = 0; i < _yAxisCount + 1; i++) {
        CGFloat avgValue = _yAxisMaxValue / (_yAxisCount);
        NSString *title = [NSString stringWithFormat:@"%.0f", avgValue * i];
        UILabel *label = [self labelWithTextColor:_yTextColor backColor:[UIColor clearColor] textAlignment:NSTextAlignmentRight lineNumber:1 tiltle:title fontSize:_axisFontSize];
        if (_yAxisLabelUIBlock) {
            _yAxisLabelUIBlock(label, i);
        }
        label.LC_x = 0;
        label.LC_height = axisLabelHieght;
        label.LC_width = _yAxisToLeft - _yTextToAxis;
        label.LC_centerY = _topMargin + (_yAxisCount - i) * yTextCenterMargin;
        [self addSubview:label];
        [self.yAxisLabels addObject:label];
        if (i == _yAxisCount) {
            CGFloat labelDW_h = [LCMethod sizeWithText:_labelDWString fontSize:9].height;//@"(单位/min)"
//            CGFloat labelDW_w = [LCMethod sizeWithText:_labelDWString fontSize:9].width;//@"(单位/min)"
//            CGFloat y = CGRectGetMaxY(label.frame) - axisLabelHieght;
//            CGFloat labelDW_y = y - labelDW_h - 5;
            UILabel *labelDW = [[UILabel alloc] initWithFrame:CGRectMake(0,10,50,labelDW_h)];
            labelDW.textColor = _axisColor;
            labelDW.font = [UIFont systemFontOfSize:9];
            labelDW.textAlignment = NSTextAlignmentCenter;
//            labelDW.backgroundColor = [UIColor redColor];
            labelDW.text = _labelDWString;//@"(单位/min)";
            labelDW.tag = 120;
            [self addSubview:labelDW];
        }else if(i == 0){
            label.hidden = YES;
        }
    }
    [self.allSubView addObjectsFromArray:self.yAxisLabels];
    
    // yTitleLabel
    _yAxisLabel = [self labelWithTextColor:_axisColor backColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft lineNumber:1 tiltle:self.yAxisTitle fontSize:_axisTitleSizeFont];
    if (_yAxisTitleLabelUIBlock) {
        _yAxisTitleLabelUIBlock(_yAxisLabel);
    }
    [_yAxisLabel sizeToFit];
    _yAxisLabel.LC_y = yAxisMaxY - _yAxisLabel.LC_height - 5;
    _yAxisLabel.LC_centerX = _originPoint.x;
    [self addSubview:_yAxisLabel];
    [self.allSubView addObject:_yAxisLabel];
    
    // 添加scrollview
    [self insertSubview:self.scrollView atIndex:0];
    self.scrollView.frame = CGRectMake(_yAxisToLeft, 0, self.LC_width - _yAxisToLeft, self.LC_height);
    
    self.scrollView.backgroundColor = self.backgroundColor = _backColor;
}

#pragma mark - 描绘X轴
- (void)drawXAxis {
    // 添加X轴Label
    for (int i = 0; i < self.xAxisTitleArray.count; i++) {
        NSString *title = self.xAxisTitleArray[i];
        
        UILabel *label = [self labelWithTextColor:_xTextColor backColor:[UIColor clearColor] textAlignment:NSTextAlignmentCenter lineNumber:1 tiltle:title fontSize:_axisFontSize];
        if (_xAxisLabelUIBlock) {
            _xAxisLabelUIBlock(label, i);
        }
        CGSize labelSize = [LCMethod sizeWithText:title fontSize:_axisFontSize];
        label.LC_x = (i + 1) * _xAxisTextMargin - labelSize.width / 2;
        label.LC_y = self.LC_height - labelSize.height;
        label.LC_size = labelSize;
        [self.scrollView addSubview:label];
        [self.xAxisLabels addObject:label];
    }
    [self.allSubView addObjectsFromArray:self.xAxisLabels];
    // 处理重叠label
    [self handleOverlapViewWithViews:self.xAxisLabels];
    // 画轴
    UIBezierPath *xAxisPath = [UIBezierPath bezierPath];
    [xAxisPath moveToPoint:CGPointMake(0, _originPoint.y)];
    xAxisMaxX = (self.xAxisTitleArray.count + 1) * _xAxisTextMargin;
    
    // scrollView的contentSize
    self.scrollView.contentSize = CGSizeMake(xAxisMaxX + self.chartViewRightMargin, 0);
    
    [xAxisPath addLineToPoint:CGPointMake(xAxisMaxX, _originPoint.y)];
    //画x轴箭头
//    [xAxisPath addLineToPoint:CGPointMake(xAxisMaxX - (_axisWidth + 2), _originPoint.y - (_axisWidth + 2))];
//    [xAxisPath moveToPoint:CGPointMake(xAxisMaxX, _originPoint.y)];
//    [xAxisPath addLineToPoint:CGPointMake(xAxisMaxX - (_axisWidth + 2) , _originPoint.y + (_axisWidth + 2))];
    CAShapeLayer *xAxisLayer = [self shapeLayerWithPath:xAxisPath lineWidth:_axisWidth fillColor:[UIColor clearColor] strokeColor:_axisColor];
    [self.scrollView.layer addSublayer:xAxisLayer];
    [self.firstLayers addObject:xAxisLayer];
    
    // xTitleLabel
    _xAxisLabel = [self labelWithTextColor:_axisColor backColor:[UIColor clearColor] textAlignment:NSTextAlignmentCenter lineNumber:1 tiltle:self.xAxisTitle fontSize:_axisTitleSizeFont];
    if (_xAxisTitleLabelUIBlock) {
        _xAxisTitleLabelUIBlock(_xAxisLabel);
    }
    [_xAxisLabel sizeToFit];
    _xAxisLabel.LC_left = xAxisMaxX + 5;
    _xAxisLabel.LC_centerY = _originPoint.y;
    [self.scrollView addSubview:_xAxisLabel];
    [self.allSubView addObject:_xAxisLabel];
    CGSize labelSize1 = [LCMethod sizeWithText:@"1" fontSize:_axisFontSize];
    CGFloat view_y = self.LC_height - labelSize1.height;
    CGFloat view_w = self.scrollView.contentSize.width;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, view_y, view_w, labelSize1.height)];
    view.tag = 121;
    view.backgroundColor = [UIColor whiteColor];
    [self.scrollView insertSubview:view atIndex:0];
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, view_y+0.5, _yAxisToLeft, labelSize1.height-0.5)];
    view2.backgroundColor = [UIColor whiteColor];
    view2.tag = 122;
    [self insertSubview:view2 atIndex:0];

    
}

- (void)drawOtherXAxis {
    // 添加X轴Label
    for (int i = 0; i < self.xAxisTitleArray.count; i++) {
        NSString *title = self.xAxisTitleArray[i];
        
        UILabel *label = [self labelWithTextColor:_xTextColor backColor:[UIColor clearColor] textAlignment:NSTextAlignmentCenter lineNumber:1 tiltle:title fontSize:_axisFontSize];
        if (_xAxisLabelUIBlock) {
            _xAxisLabelUIBlock(label, i);
        }
        CGSize labelSize = [LCMethod sizeWithText:title fontSize:_axisFontSize];
        label.LC_x = (i + 1) * _xAxisTextMargin - labelSize.width / 2;
        label.LC_y = self.LC_height - labelSize.height;
        label.LC_size = labelSize;
        [self.scrollView addSubview:label];
        [self.xAxisLabels addObject:label];
    }
    [self.allSubView addObjectsFromArray:self.xAxisLabels];
    // 处理重叠label
    [self handleOverlapViewWithViews:self.xAxisLabels];
    // 画轴
    UIBezierPath *xAxisPath = [UIBezierPath bezierPath];
    [xAxisPath moveToPoint:CGPointMake(0, _originPoint.y)];
    xAxisMaxX = (self.xAxisTitleArray.count + 1) * _xAxisTextMargin;
    
    // scrollView的contentSize
    self.scrollView.contentSize = CGSizeMake(xAxisMaxX + self.chartViewRightMargin, 0);
    
    [xAxisPath addLineToPoint:CGPointMake(xAxisMaxX, _originPoint.y)];
    //画x轴箭头
    //    [xAxisPath addLineToPoint:CGPointMake(xAxisMaxX - (_axisWidth + 2), _originPoint.y - (_axisWidth + 2))];
    //    [xAxisPath moveToPoint:CGPointMake(xAxisMaxX, _originPoint.y)];
    //    [xAxisPath addLineToPoint:CGPointMake(xAxisMaxX - (_axisWidth + 2) , _originPoint.y + (_axisWidth + 2))];
    CAShapeLayer *xAxisLayer = [self shapeLayerWithPath:xAxisPath lineWidth:_axisWidth fillColor:[UIColor clearColor] strokeColor:_axisColor];
    [self.scrollView.layer addSublayer:xAxisLayer];
    [self.firstLayers addObject:xAxisLayer];
    
    // xTitleLabel
    _xAxisLabel = [self labelWithTextColor:_axisColor backColor:[UIColor clearColor] textAlignment:NSTextAlignmentCenter lineNumber:1 tiltle:self.xAxisTitle fontSize:_axisTitleSizeFont];
    if (_xAxisTitleLabelUIBlock) {
        _xAxisTitleLabelUIBlock(_xAxisLabel);
    }
    [_xAxisLabel sizeToFit];
    _xAxisLabel.LC_left = xAxisMaxX + 5;
    _xAxisLabel.LC_centerY = _originPoint.y;
    [self.scrollView addSubview:_xAxisLabel];
    [self.allSubView addObject:_xAxisLabel];
    CGSize labelSize1 = [LCMethod sizeWithText:@"1" fontSize:_axisFontSize];
    CGFloat view_y = self.LC_height - labelSize1.height;
    CGFloat view_w = self.scrollView.contentSize.width;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, view_y, view_w, labelSize1.height)];
    view.tag = 121;
    view.backgroundColor = [UIColor whiteColor];
    [self.scrollView insertSubview:view atIndex:0];
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, view_y+0.5, _yAxisToLeft, labelSize1.height-0.5)];
    view2.backgroundColor = [UIColor whiteColor];
    view2.tag = 122;
    [self insertSubview:view2 atIndex:0];
    
    
}

#pragma mark - 标题
- (void)drawTilte {
    // titleLabel
    UILabel *titleLabel = [self labelWithTextColor:_axisColor backColor:[UIColor clearColor] textAlignment:NSTextAlignmentCenter lineNumber:1 tiltle:_title fontSize:_titleFontSize];
    if (_comfigurateTitleLabel) {
        _comfigurateTitleLabel(titleLabel);
    }
    [titleLabel sizeToFit];
    titleLabel.LC_centerX = self.LC_width / 2;
    titleLabel.LC_y = 5;
    [self addSubview:titleLabel];
    [self.allSubView addObject:titleLabel];
}

#pragma mark - Y轴分割线
- (void)drawYSeparators {
    // 添加Y轴分割线
    for (int i = 0; i < self.yAxisLabels.count; i++) {
        CAShapeLayer *yshapeLayer = nil;
        UIBezierPath *ySeparatorPath = [UIBezierPath bezierPath];
        if (_showGridding) {
            [ySeparatorPath moveToPoint:CGPointMake(0, self.yAxisLabels[i].LC_centerY)];
            [ySeparatorPath addLineToPoint:CGPointMake(xAxisMaxX, self.yAxisLabels[i].LC_centerY)];
            yshapeLayer = [self shapeLayerWithPath:ySeparatorPath lineWidth:0.5 fillColor:[UIColor clearColor] strokeColor:_axisColor];
            yshapeLayer.lineDashPattern = @[@(3), @(3)];
            [self.scrollView.layer addSublayer:yshapeLayer];
        } else {
            [ySeparatorPath moveToPoint:CGPointMake(_yAxisToLeft, self.yAxisLabels[i].LC_centerY)];
            [ySeparatorPath addLineToPoint:CGPointMake(_yAxisToLeft + 5, self.yAxisLabels[i].LC_centerY)];
            yshapeLayer = [self shapeLayerWithPath:ySeparatorPath lineWidth:_axisWidth fillColor:[UIColor clearColor] strokeColor:_axisColor];
            [self.layer addSublayer:yshapeLayer];
        }
        [self.firstLayers addObject:yshapeLayer];
    }
}

#pragma mark - X轴分割线
- (void)drawXSeparators {
    // 添加X轴分割线
    for (int i = 0; i < self.xAxisLabels.count; i++) {
        CAShapeLayer *xshapeLayer = nil;
        UIBezierPath *xSeparatorPath = [UIBezierPath bezierPath];
        [xSeparatorPath moveToPoint:CGPointMake(self.xAxisLabels[i].LC_centerX, _originPoint.y)];
        if (_showGridding) {
            [xSeparatorPath addLineToPoint:CGPointMake(self.xAxisLabels[i].LC_centerX, self.yAxisLabels.lastObject.LC_centerY)];
            xshapeLayer = [self shapeLayerWithPath:xSeparatorPath lineWidth:0.5 fillColor:[UIColor clearColor] strokeColor:_axisColor];
            xshapeLayer.lineDashPattern = @[@(3), @(3)];
        } else {
            [xSeparatorPath addLineToPoint:CGPointMake(self.xAxisLabels[i].LC_centerX, _originPoint.y - 5)];
            xshapeLayer = [self shapeLayerWithPath:xSeparatorPath lineWidth:_axisWidth fillColor:[UIColor clearColor] strokeColor:_axisColor];
        }
        [self.scrollView.layer addSublayer:xshapeLayer];
        [self.firstLayers addObject:xshapeLayer];
    }
}

#pragma mark - 显示数据label
- (void)drawDisplayLabels {
    if (!_showPlotsLabel) {
        return;
    }
    // 多组数据显示label太混乱
    if (_chartViewType == LCChartViewTypeLine && self.dataSource.count > 1) {
        return;
    }
    NSInteger centerFlag = self.dataSource.count / 2;
    for (int i = 0 ; i < self.dataSource.count; i++) {
        LCChartViewModel *model = self.dataSource[i];
        NSMutableArray *plotLabels = [NSMutableArray array];
        for (int j = 0; j < model.plots.count; j++) {
            NSString *value = model.plots[j];
            if (value.floatValue < 0) {
                value = @"0";
            }
            UILabel *label = [self labelWithTextColor:self.plotsLabelColor backColor:[UIColor clearColor] textAlignment:NSTextAlignmentCenter lineNumber:1 tiltle:value fontSize:self.plotsLabelFontSize];
            label.tag = j;
            [label sizeToFit];
            switch (self.chartViewType) {
                case LCChartViewTypeLine:{
                    label.LC_centerX = self.xAxisLabels[j].LC_centerX;
                }
                    break;
                case LCChartViewTypeBar:{
                    if (self.dataSource.count % 2 == 0) { // 双数组
                        label.LC_centerX = self.xAxisLabels[j].LC_centerX + ( 1/2.0 + i - centerFlag) * _barWidth;
                    } else { // 单数组
                        label.LC_centerX = self.xAxisLabels[j].LC_centerX + (i - centerFlag) * _barWidth;
                    }
                }
                    break;
                    
                default:
                    break;
            }
            label.LC_bottom = [self getValueHeightWith:value] - _displayPlotToLabel;
            [self.scrollView addSubview:label];
            [plotLabels addObject:label];
            [self.allSubView addObjectsFromArray:plotLabels];
            // 处理重叠label
            [self handleOverlapViewWithViews:plotLabels];
        }
    }
}

- (void)drawOtherDisplayLabels {
    if (!_showPlotsLabel) {
        return;
    }
    // 多组数据显示label太混乱
    if (_chartViewType == LCChartViewTypeLine && self.dataOtherSource.count > 1) {
        return;
    }
    NSInteger centerFlag = self.dataOtherSource.count / 2;
    for (int i = 0 ; i < self.dataOtherSource.count; i++) {
        LCChartViewModel *model = self.dataOtherSource[i];
        NSMutableArray *plotLabels = [NSMutableArray array];
        for (int j = 0; j < model.plotsModelArr.count; j++) {
            NSString *value = model.plotsModelArr[j];
            if (value.floatValue < 0) {
                value = @"0";
            }
            UILabel *label = [self labelWithTextColor:self.plotsLabelColor backColor:[UIColor clearColor] textAlignment:NSTextAlignmentCenter lineNumber:1 tiltle:value fontSize:self.plotsLabelFontSize];
            label.tag = j;
            [label sizeToFit];
            switch (self.chartViewType) {
                case LCChartViewTypeLine:{
                    label.LC_centerX = self.xAxisLabels[j].LC_centerX;
                }
                    break;
                case LCChartViewTypeBar:{
                    if (self.dataOtherSource.count % 2 == 0) { // 双数组
                        label.LC_centerX = self.xAxisLabels[j].LC_centerX + ( 1/2.0 + i - centerFlag) * _barWidth;
                    } else { // 单数组
                        label.LC_centerX = self.xAxisLabels[j].LC_centerX + (i - centerFlag) * _barWidth;
                    }
                }
                    break;
                    
                default:
                    break;
            }
            label.LC_bottom = [self getValueHeightWith:value] - _displayPlotToLabel;
            [self.scrollView addSubview:label];
            [plotLabels addObject:label];
            [self.allSubView addObjectsFromArray:plotLabels];
            // 处理重叠label
            [self handleOverlapViewWithViews:plotLabels];
        }
    }
}

#pragma mark - 描绘折线图点和线
/** 描述折线图数据点 */
- (void)drawLineChartViewPots {
    for (int i = 0; i < self.dataSource.count; i++) {
        LCChartViewModel *model = self.dataSource[i];
        if (model.plotButtons.count) {
            [model.plotButtons removeAllObjects];
            [model.plotButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        // 画点
        for (int j = 0; j < model.plots.count; j++) {
            // 添加数据点button
            UIButton *button = [[UIButton alloc] init];
            [button addTarget:self action:@selector(plotsButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
            if (self.plotsButtonImage.length && self.plotsButtonSelectedImage.length) {
                [button setBackgroundImage:[UIImage imageNamed:self.plotsButtonImage] forState:UIControlStateNormal];
                [button setBackgroundImage:[UIImage imageNamed:self.plotsButtonSelectedImage] forState:UIControlStateSelected];
            } else {
                [button setBackgroundImage:[LCMethod imageFromColor:self.plotsButtonColor rect:CGRectMake(0, 0, 1, 1)] forState:UIControlStateNormal];
                [button setBackgroundImage:[LCMethod imageFromColor:self.plotsButtonSelectedColor rect:CGRectMake(0, 0, 1, 1)] forState:UIControlStateSelected];
            }
            button.tag = j;
            button.LC_size = CGSizeMake(self.plotsButtonWH, self.plotsButtonWH);
            button.center = CGPointMake(self.xAxisLabels[j].LC_centerX, [self getValueHeightWith:model.plots[j]]);
            button.layer.cornerRadius = self.plotsButtonWH / 2;
            button.layer.masksToBounds = YES;

            [self.allSubView addObject:button];
            [model.plotButtons addObject:button];
            [self.scrollView addSubview:button];
            // 处理重叠点
            [self handleOverlapViewWithViews:model.plotButtons];
        }
    }
}

/** 根据数据点画线 */
- (void)drawLineChartViewLines {
    for (LCChartViewModel *model in self.dataSource) {
        UIBezierPath *lineChartPath = [UIBezierPath bezierPath];
        // 填充
        CAShapeLayer *lineShapeLayer = nil;
        if (self.lineChartFillView) {
            [lineChartPath moveToPoint:CGPointMake(model.plotButtons.firstObject.center.x, _originPoint.y)];
            for (int i = 0; i < model.plotButtons.count; i++) {
                [lineChartPath addLineToPoint:model.plotButtons[i].center];
            }
            [lineChartPath addLineToPoint:CGPointMake(model.plotButtons.lastObject.center.x, _originPoint.y)];
            lineShapeLayer = [LCMethod shapeLayerWithPath:lineChartPath lineWidth:self.lineChartWidth fillColor:self.lineChartFillViewColor strokeColor:model.color];
        } else {
            // 不填充
            [lineChartPath moveToPoint:model.plotButtons.firstObject.center];
            for (int i = 1; i < model.plotButtons.count; i++) {
                [lineChartPath addLineToPoint:model.plotButtons[i].center];
            }
            lineShapeLayer = [self shapeLayerWithPath:lineChartPath lineWidth:self.lineChartWidth fillColor:[UIColor clearColor] strokeColor:model.color];
        }
        [self.scondLayers addObject:lineShapeLayer];
        [self.scrollView.layer insertSublayer:lineShapeLayer below:model.plotButtons.firstObject.layer];
    }
    
}

#pragma mark - ChartViewBar柱状图
/** 根据显示点描绘柱状图 */
- (void)drawBarChartViewBars {
    NSInteger centerFlag = self.dataSource.count / 2;
    for (int i = 0; i < self.dataSource.count; i++) {
        LCChartViewModel *model = self.dataSource[i];
        for (int j = 0; j < model.plots.count; j++) {
            UIBezierPath *barPath = [UIBezierPath bezierPath];
            CGFloat startPointX = 0;
            switch (self.dataSource.count % 2) {
                case 0:{ // 双数组
                    startPointX = self.xAxisLabels[j].LC_centerX + ( 1/2.0 + i - centerFlag) * _barWidth;
                }
                    break;
                case 1:{ // 单数组
                    startPointX = self.xAxisLabels[j].LC_centerX + (i - centerFlag) * _barWidth;
                }
                    break;
                default:
                    break;
            }
            [barPath moveToPoint:CGPointMake(startPointX, _originPoint.y)];
            [barPath addLineToPoint:CGPointMake(startPointX, [self getValueHeightWith:model.plots[j]])];
            CAShapeLayer *barShapeLayer = [self shapeLayerWithPath:barPath lineWidth:_barWidth fillColor:model.color strokeColor:model.color];
            [self.scondLayers addObject:barShapeLayer];
            [self.scrollView.layer addSublayer:barShapeLayer];
        }
    }
}

- (CGSize)sizeWithString:(NSString *)string font:(CGFloat)font maxWidth:(CGFloat)maxWidth

{
    
    NSDictionary *attributesDict = @{NSFontAttributeName:[UIFont systemFontOfSize:font]};
    
    CGSize maxSize = CGSizeMake(maxWidth, MAXFLOAT);
    
    CGRect subviewRect = [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDict context:nil];
    return subviewRect.size;
}

- (void)drawBarOtherChartViewBars {
    
    NSInteger centerFlag = self.dataOtherSource.count / 2;
    NSMutableArray *arr = [NSMutableArray array];
    NSMutableArray *arr1 = [NSMutableArray array];

    for (int i = 0; i < self.dataOtherSource.count; i++) {
        LCChartViewModel *model = self.dataOtherSource[i];
        for (int j = 0; j < model.plotsModelArr.count; j++) {
            for (LGTodayStateModel *newModel in model.plotsModelArr) {
                NSString *str = newModel.sit_time;
                [arr addObject:str];
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];

                NSString *start_time = newModel.start_time;
                NSArray *array = [start_time componentsSeparatedByString:@":"];
                [dict setObject:array[0] forKey:@"index"];
                [dict setObject:array[1] forKey:@"from"];
                
                NSInteger fromInt = [array[1] integerValue];
                NSInteger toInt = [newModel.sit_time integerValue];
                NSInteger endInt = fromInt + toInt;//
                NSInteger yuInt = endInt%60;
                NSInteger shangInt = endInt/60;
                NSInteger lastResultFromInt = [array[0] integerValue] + shangInt;
                NSInteger lastResultToInt = yuInt;
                NSString *lastStr = [NSString stringWithFormat:@"%02ld:%02ld",(long)lastResultFromInt,(long)lastResultToInt];
                [dict setObject:str forKey:@"to"];
                [dict setObject:lastStr forKey:@"endTime"];
                [dict setObject:[NSString stringWithFormat:@"%ld",shangInt] forKey:@"shang"];
                [dict setObject:[NSString stringWithFormat:@"%ld",yuInt] forKey:@"yu"];
                CGFloat toto = [str floatValue];
                CGFloat wiw = 0;
                if (shangInt > 0) {
                    wiw += (shangInt)*60;
                    wiw += yuInt;
                    toto = wiw;
                }
                [dict setObject:[NSString stringWithFormat:@"%.2f",toto] forKey:@"finalWidth"];
                [arr1 addObject:dict];
                
            }
        }
    }
    
    for (int i = 0; i < self.dataOtherSource.count; i++) {
        LCChartViewModel *model = self.dataOtherSource[i];
        for (int j = 0; j < model.plotsModelArr.count; j++) {
            
            UIBezierPath *barPath = [UIBezierPath bezierPath];
            CGFloat startPointX = 0;
            switch (self.dataOtherSource.count % 2) {
                case 0:{ // 双数组
                    startPointX = self.xAxisLabels[j].LC_centerX + ( 1/2.0 + i - centerFlag) * _barWidth+_barMargin;
                }
                    break;
                case 1:{ // 单数组
//                    startPointX = self.xAxisLabels[j].LC_centerX + (i - centerFlag) * _barWidth;
                    NSDictionary *dict1 = arr1[j];
                    NSInteger index = [dict1[@"index"] integerValue]-1;
                    CGFloat from = [dict1[@"from"] floatValue];
                    CGFloat fromValue = (from /60.0)* (_barWidth+_barMargin);

                    UILabel *label1 = self.xAxisLabels[index];
                    CGFloat fV = label1.frame.size.width;
                    CGFloat fVX = label1.frame.origin.x;

                    NSLog(@"=======~~%@,%ld,width = %.2f,x = %.2f",arr1[j],index,fV,fVX);
                    CGFloat finalWidth = [dict1[@"to"] floatValue];
                    CGFloat offset = ((finalWidth/60.0)*(_barWidth+_barMargin) - (_barWidth+_barMargin))/2.0;
                    startPointX =
                    self.xAxisLabels[index].LC_centerX+ offset + fromValue;
                    
                }
                    break;
                default:
                    break;
            }

            NSDictionary *dict1 = arr1[j];
            CGFloat width = ([dict1[@"to"] floatValue]/60.0)* (_barWidth+_barMargin);
            
            [barPath moveToPoint:CGPointMake(startPointX, _originPoint.y)];
            
            [barPath addLineToPoint:CGPointMake(startPointX, [self getValueHeightWith:arr[j]])];
            UIColor *color = model.color;
            if([arr[j] floatValue]<40){
                color = [UIColor colorWithRed:35/255.0 green:255.0/255.0 blue:6/255.0 alpha:1.0];
            }else {
                LGTodayStateModel *md = model.plotsModelArr[j];
                NSDictionary *dict1 = arr1[j];
                NSString *endTime = dict1[@"endTime"];
                
                NSString *string = [NSString stringWithFormat:@"%@-%@",md.start_time,endTime];
                CGFloat w = [LCMethod sizeWithText:string fontSize:9].width;
                NSString *string1 = [NSString stringWithFormat:@"%@-%@\n(%@min)",md.start_time,endTime,md.sit_time];
                
                CGSize size = [self sizeWithString:string1 font:9 maxWidth:w];
                
                CGFloat x = startPointX - w/2.0;
                CGFloat y = [self getValueHeightWith:arr[j]] - size.height - 2;
                CGRect rect = CGRectMake(x, y, w, size.height);
                //label添加到scrollview上会被柱状图遮挡，最后改成用CATextLayer来绘制文本
                //                UILabel *label = [[UILabel alloc] initWithFrame:rect];
                //                label.textColor = [UIColor whiteColor];
                //                label.font = [UIFont systemFontOfSize:9];
                //                label.textAlignment = NSTextAlignmentCenter;
                //                label.text = string1;
                //                label.numberOfLines = 0;
                //                [self.scrollView addSubview:label];
                //                [self.scrollView
                
                // 绘制文本的图层
                CATextLayer *layerText = [[CATextLayer alloc] init];
                // 背景颜色
                layerText.backgroundColor = [UIColor clearColor].CGColor;
                // 渲染分辨率-重要，否则显示模糊
                layerText.contentsScale = [UIScreen mainScreen].scale;
                layerText.wrapped = YES;
                
                layerText.foregroundColor = [UIColor whiteColor].CGColor;
                UIFont *font = [UIFont systemFontOfSize:9.0];
                CFStringRef fontName = (__bridge CFStringRef)font.fontName;
                CGFontRef fontRef =CGFontCreateWithFontName(fontName);
                layerText.font = fontRef;
                layerText.fontSize = font.pointSize;
                layerText.alignmentMode = kCAAlignmentCenter;
                // 显示位置
                layerText.frame = rect;//CGRectMake(0.0, 0.0, 100.0, 50.0);
                layerText.string = string1;
                //先添加到数组
                [self.textLayers addObject:layerText];
                //先不添加到scrollviewLayer层
//                [self.scrollView.layer insertSublayer:layerText above:barShapeLayer];

            }
            CAShapeLayer *barShapeLayer = [self shapeLayerWithPath:barPath lineWidth:width fillColor:color strokeColor:color];
            [self.scondLayers addObject:barShapeLayer];
            [self.scrollView.layer addSublayer:barShapeLayer];
        }
    }
    
    //最后再绘制label,不然会被柱状图遮挡
    if (self.textLayers.count>0) {
        for (CATextLayer *layerText in self.textLayers) {
            [self.scrollView.layer addSublayer:layerText];
        }
    }
    
}


#pragma mark - private method
/** 处理label重叠显示的情况 */
- (void)handleOverlapViewWithViews:(NSArray <UIView *>*)views {
    // 如果Label的文字有重叠，那么隐藏
    UIView *firstView = views.firstObject;
    for (int i = 1; i < views.count; i++) {
        UIView *view = views[i];
        CGFloat maxX = CGRectGetMaxX(firstView.frame);
        if ((maxX + 3) > view.LC_x) {
            view.hidden = YES;
        }else{
            view.hidden = NO;
            firstView = view;
        }
    }
}

- (CAShapeLayer *)shapeLayerWithPath:(UIBezierPath *)path lineWidth:(CGFloat)lineWidth fillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.lineWidth = lineWidth;
    shapeLayer.fillColor = fillColor.CGColor;
    shapeLayer.strokeColor = strokeColor.CGColor;
    shapeLayer.lineCap = kCALineCapButt;
    shapeLayer.lineJoin = kCALineJoinBevel;
    shapeLayer.path = path.CGPath;
    return shapeLayer;
}

/** 数据点高度 */
- (CGFloat)getValueHeightWith:(NSString *)value {
    return dataChartHeight - value.floatValue / _yAxisMaxValue * dataChartHeight + _topMargin;
}

/** label */
- (UILabel *)labelWithTextColor:(UIColor *)textColor backColor:(UIColor *)backColor textAlignment:(NSTextAlignment)textAlignment lineNumber:(NSInteger)number tiltle:(NSString *)title fontSize:(CGFloat)fontSize {
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.textColor = textColor;
    if (backColor) {
        label.backgroundColor = backColor;
    }
    label.textAlignment = textAlignment;
    label.numberOfLines = number;
    if (fontSize != 0) {
        label.font = [UIFont systemFontOfSize:fontSize];
    }
    
    return label;
}

/** 根据颜色生成图片 */
+ (UIImage *)imageFromColor:(UIColor *)color rect:(CGRect)rect{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)addAnimation:(NSArray <CAShapeLayer *>*)shapeLayers delegate:(id<CAAnimationDelegate>)delegate duration:(NSTimeInterval)duration {
    CABasicAnimation *stroke = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    stroke.delegate = delegate;
    stroke.duration = duration;
    stroke.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    stroke.fromValue = [NSNumber numberWithFloat:0.0f];
    stroke.toValue = [NSNumber numberWithFloat:1.0f];
    for (CAShapeLayer *shapeLayer in shapeLayers) {
        [shapeLayer addAnimation:stroke forKey:nil];
    }
}

#pragma mark - response

- (void)plotsButtonDidClick:(UIButton *)button {
    if (self.plotClickBlock) {
        self.plotClickBlock(button.tag);
    }
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    for (CAShapeLayer *layer in self.scondLayers) {
        layer.hidden = NO;
    }
    [self addAnimation:self.scondLayers delegate:nil duration:duration];
    
    if (self.textLayers.count) {
        for (CATextLayer *layer in self.textLayers) {
            layer.hidden = NO;
        }
        [self addAnimation:self.textLayers delegate:nil duration:duration];
    }
    [self.allSubView enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [UIView animateWithDuration:duration animations:^{
            obj.alpha = 1.0;
        }];
    }];
}


#pragma mark - scrollview的手势支持
/** 双击 */
- (void)tapGesture:(UITapGestureRecognizer *)tap {
//    _xAxisTextMargin *= 1.5;
//    self.orginXAxisMargin = _xAxisTextMargin;
    [self showChartView];
}

/** 捏合 */
- (void)pinchGesture:(UIPinchGestureRecognizer *)recognizer {

    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:{
            self.orginAnimation = self.showAnimation;
            self.showAnimation = NO;
        }
            break;
        case UIGestureRecognizerStateChanged:{
            _xAxisTextMargin = recognizer.scale * self.orginXAxisMargin;

            
            _barWidth = recognizer.scale*self.midBarWidth;
            if (_barWidth < self.originBarWidth) {
                _barWidth = self.originBarWidth;
            }
            if (_isLianxu) {
                
                [self showOtherChartView];
            }else {
                [self showChartView];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:{
            self.orginXAxisMargin = _xAxisTextMargin;
            self.showAnimation = self.orginAnimation;
//            if (_isLianxu) {
                self.midBarWidth = _barWidth;
//            }
        }
            break;
            
        default:
            break;
    }
}

/** addAnimation */
- (void)addAnimation:(BOOL)animation {
    if (animation) {
        [self.allSubView enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.alpha = 0.0;
        }];
        for (CAShapeLayer *layer in self.scondLayers) {
            layer.hidden = YES;
        }
        if (self.textLayers.count) {
            for (CATextLayer *layer1 in self.textLayers) {
                layer1.hidden = YES;
            }
        }
        
        [self addAnimation:self.firstLayers delegate:self duration:0.5];
    }
}

/** 添加注释 */
- (void)addNote {
    if (!_showNote) {
        return;
    }
    if (_noteView) {
        [_noteView removeFromSuperview];
        _noteView = nil;
    }
    [self addSubview:self.noteView];
    for (int i = 0; i < self.dataSource.count; i ++) {
        LCChartViewModel *model = self.dataSource[i];
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        view.frame = CGRectMake(0, noteViewRowH * i, self.noteView.LC_width, noteViewRowH);
        [self.noteView addSubview:view];
        // label
        UILabel *label = [self labelWithTextColor:_yTextColor backColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft lineNumber:1 tiltle:model.project fontSize:_axisFontSize];
        label.adjustsFontSizeToFitWidth = YES;
        label.frame = CGRectMake(view.LC_width / 2 + 10, 0, view.LC_width / 2, view.LC_height);
        [view addSubview:label];
        label.hidden = YES;
        [self.allSubView addObject:label];
        
        if (self.chartViewType == LCChartViewTypeLine) {
            // 画线
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(0, view.LC_height / 2)];
            [path addLineToPoint:CGPointMake(self.noteView.LC_width / 2 , view.LC_height / 2)];
            
            CAShapeLayer *shapeLayer = [self shapeLayerWithPath:path lineWidth:2 fillColor:[UIColor clearColor] strokeColor:model.color];
            [view.layer addSublayer:shapeLayer];
            [self.firstLayers addObject:shapeLayer];
        } else {
            // 方块
//            UIBezierPath *path = [UIBezierPath bezierPath];
//            CGFloat squareH = noteViewRowH - 2 * 2;
//            [path moveToPoint:CGPointMake(view.LC_width / 2 - squareH, view.LC_height / 2)];
//            [path addLineToPoint:CGPointMake(view.LC_width / 2 , view.LC_height / 2)];
//
//            CAShapeLayer *shapeLayer = [self shapeLayerWithPath:path lineWidth:squareH fillColor:[UIColor clearColor] strokeColor:model.color];
//            [view.layer addSublayer:shapeLayer];
//            [self.firstLayers addObject:shapeLayer];
        }
    }
    self.noteView.contentSize = CGSizeMake(0, noteViewRowH * self.dataSource.count);
}

- (void)addOtherNote {
    if (!_showNote) {
        return;
    }
    if (_noteView) {
        [_noteView removeFromSuperview];
        _noteView = nil;
    }
    [self addSubview:self.noteView];
    for (int i = 0; i < self.dataOtherSource.count; i ++) {
        LCChartViewModel *model = self.dataOtherSource[i];
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        view.frame = CGRectMake(0, noteViewRowH * i, self.noteView.LC_width, noteViewRowH);
        [self.noteView addSubview:view];
        // label
        UILabel *label = [self labelWithTextColor:_yTextColor backColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft lineNumber:1 tiltle:model.project fontSize:_axisFontSize];
        label.adjustsFontSizeToFitWidth = YES;
        label.frame = CGRectMake(view.LC_width / 2 + 10, 0, view.LC_width / 2, view.LC_height);
        [view addSubview:label];
        label.hidden = YES;
        [self.allSubView addObject:label];
        
        if (self.chartViewType == LCChartViewTypeLine) {
            // 画线
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(0, view.LC_height / 2)];
            [path addLineToPoint:CGPointMake(self.noteView.LC_width / 2 , view.LC_height / 2)];
            
            CAShapeLayer *shapeLayer = [self shapeLayerWithPath:path lineWidth:2 fillColor:[UIColor clearColor] strokeColor:model.color];
            [view.layer addSublayer:shapeLayer];
            [self.firstLayers addObject:shapeLayer];
        } else {
            // 方块
            //            UIBezierPath *path = [UIBezierPath bezierPath];
            //            CGFloat squareH = noteViewRowH - 2 * 2;
            //            [path moveToPoint:CGPointMake(view.LC_width / 2 - squareH, view.LC_height / 2)];
            //            [path addLineToPoint:CGPointMake(view.LC_width / 2 , view.LC_height / 2)];
            //
            //            CAShapeLayer *shapeLayer = [self shapeLayerWithPath:path lineWidth:squareH fillColor:[UIColor clearColor] strokeColor:model.color];
            //            [view.layer addSublayer:shapeLayer];
            //            [self.firstLayers addObject:shapeLayer];
        }
    }
    self.noteView.contentSize = CGSizeMake(0, noteViewRowH * self.dataSource.count);
}
#pragma mark - setter

- (void)setXAxisTextMargin:(CGFloat)xAxisTextMargin {
    _xAxisTextMargin = xAxisTextMargin;
    _xArrowsToText = xAxisTextMargin;
}

- (void)setChartViewXAxisTextMargin:(CGFloat)xAxisTextMargin {
    _xAxisTextMargin = xAxisTextMargin;
    _orginXAxisMargin = xAxisTextMargin;
}

#pragma mark - getter

- (NSMutableArray<UILabel *> *)yAxisLabels {
    if (!_yAxisLabels) {
        _yAxisLabels = [[NSMutableArray alloc] init];
    }
    return _yAxisLabels;
}

- (NSMutableArray<UILabel *> *)xAxisLabels {
    if (!_xAxisLabels) {
        _xAxisLabels = [[NSMutableArray alloc] init];
    }
    return _xAxisLabels;
}

- (NSMutableArray<CAShapeLayer *> *)firstLayers {
    if (!_firstLayers) {
        _firstLayers = [[NSMutableArray alloc] init];
    }
    return _firstLayers;
}

- (NSMutableArray<CAShapeLayer *> *)scondLayers {
    if (!_scondLayers) {
        _scondLayers = [[NSMutableArray alloc] init];
    }
    return _scondLayers;
}

- (NSMutableArray *)textLayers {
    if (!_textLayers) {
        _textLayers = [[NSMutableArray alloc] init];
    }
    return _textLayers;
}

- (NSMutableArray<UIView *> *)allSubView {
    if (!_allSubView) {
        _allSubView = [[NSMutableArray alloc] init];
    }
    return _allSubView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.bounces = NO;
        // 双击事件
        [_scrollView addGestureRecognizer:self.twoTap];
        // 捏合手势
        [_scrollView addGestureRecognizer:self.pinch];
    }
    return _scrollView;
}

- (UIScrollView *)noteView {
    if (!_noteView) {
        _noteView = [[UIScrollView alloc] init];
        _noteView.showsVerticalScrollIndicator = NO;
        _noteView.LC_width = 80;
        _noteView.LC_height = _topMargin - 2 * 10;
        _noteView.LC_right = self.LC_width - 10;
        _noteView.LC_y = 10;
    }
    return _noteView;
}

- (UITapGestureRecognizer *)twoTap {
    if (!_twoTap) {
        _twoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        _twoTap.numberOfTapsRequired = 2;
    }
    return _twoTap;
}

- (UIPinchGestureRecognizer *)pinch {
    if (!_pinch) {
        _pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    }
    return _pinch   ;
}

- (CGFloat)xArrowsToText {
    if (_xArrowsToText < 8) {
        return 8;
    }
    return _xArrowsToText;
}

@end
