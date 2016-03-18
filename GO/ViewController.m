//
//  ViewController.m
//  GO
//
//  Created by  rjt on 16/3/17.
//  Copyright © 2016年 JYZD. All rights reserved.
//

#import "ViewController.h"
#import "ViewModel.h"

@interface ViewController ()
- (IBAction)btnClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *boardImageView;
@property (strong, nonatomic) BoardView *boardView;

@property (strong, nonatomic) ViewModel *model;

@property (strong, nonatomic) NSArray* btnArray;

@property (strong,nonatomic) CALayer* handLayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    _model = [[ViewModel alloc] init];
    
    _boardView = [[BoardView alloc] initWithFrame:CGRectMake(80, 30, kBoardWidth, kBoardHeight)];
    
    _boardView.backgroundColor = [UIColor grayColor];
    _boardView.layer.contents = (id)[UIImage imageNamed:@"board"].CGImage;
    _handLayer = [CALayer layer];
    _handLayer.frame = CGRectMake(0, 0, kGridWidth, kGridHeight);
    [_boardView.layer addSublayer:_handLayer];
    _handLayer.hidden = YES;
    [self.view addSubview:_boardView];
    
    CGPoint point = CGPointMake(kOriginX, kOriginY);
    
    NSMutableArray* arr = [NSMutableArray array];
    for (int i=0; i< _model.goBoard.lineCount; ++i) {
        NSMutableArray* line = [NSMutableArray array];
        for (int j=0; j<_model.goBoard.colCount; ++j) {
            GridLayer* gl = [GridLayer layer];
            gl.frame = CGRectMake(point.x+kGridWidth*j, point.y+kGridHeight*i, kGridWidth, kGridHeight);
//            gl.contents = (id)[UIImage imageNamed:@"white"].CGImage;;
            gl.line = i;
            gl.col = j;
            [_boardView.layer addSublayer:gl];
        }
        [arr addObject:line];
    }
    _btnArray = [NSArray arrayWithArray:arr];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    for (UITouch *touch in allTouches) {
        if ([touch.view isKindOfClass:[BoardView class]]) {
            _handLayer.hidden = NO;
            BoardView *v = (BoardView*)touch.view;
            CGPoint point = [touch locationInView:v]; //返回触摸点在视图中的当前坐标
            [CATransaction begin];
            ///关闭隐式动画
            [CATransaction setDisableActions:YES];
            _handLayer.position = point;
            [CATransaction commit];
            if (_model.goBoard.nextChessType == ChessTypeBlack) {
                _handLayer.contents = (id)[UIImage imageNamed:@"black"].CGImage;
            }else{
                _handLayer.contents = (id)[UIImage imageNamed:@"white"].CGImage;
            }
        }
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    for (UITouch *touch in allTouches) {
        if ([touch.view isKindOfClass:[BoardView class]]) {
            BoardView *v = (BoardView*)touch.view;
            CGPoint point = [touch locationInView:v]; //返回触摸点在视图中的当前坐标
            if ([v.layer containsPoint:point]) {
                [CATransaction begin];
                ///关闭隐式动画
                [CATransaction setDisableActions:YES];
                _handLayer.position = point;
                [CATransaction commit];
            }else{
                _handLayer.hidden = YES;
            }
            

        }
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    for (UITouch *touch in allTouches) {
        if ([touch.view isKindOfClass:[BoardView class]]) {
            BoardView *v = (BoardView*)touch.view;
            CGPoint point = [touch locationInView:self.view]; //返回触摸点在视图中的当前坐标
            CALayer *gl = [v.layer hitTest:point];
            if (gl && [gl isKindOfClass:[GridLayer class]]) {
                _handLayer.hidden = YES;
                GridLayer* ll = (GridLayer*)gl;
                if (_model.goBoard.nextChessType == ChessTypeBlack) {
                    ll.contents = (id)[UIImage imageNamed:@"black"].CGImage;
                }else{
                    ll.contents = (id)[UIImage imageNamed:@"white"].CGImage;
                }
            }
        }
    }
}
@end

