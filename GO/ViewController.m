//
//  ViewController.m
//  GO
//
//  Created by  rjt on 16/3/17.
//  Copyright © 2016年 JYZD. All rights reserved.
//

#import "ViewController.h"
#import "ViewModel.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
@property (strong, nonatomic) BoardView *boardView;

@property (strong, nonatomic) ViewModel *model;

@property (strong, nonatomic) NSArray   *gridLayer;

@property (strong,nonatomic) CALayer    *handLayer;

@property (strong,nonatomic) AVAudioPlayer *avPlayer;
@property (weak, nonatomic) IBOutlet UIImageView *nextChessImage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    _model = [[ViewModel alloc] init];
    
    _boardView = [[BoardView alloc] initWithFrame:CGRectMake(30, 30, kBoardWidth, kBoardHeight)];
    
    _boardView.backgroundColor = [UIColor grayColor];
    _boardView.layer.contents = (id)[UIImage imageNamed:@"board"].CGImage;
    _boardView.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
//    _boardView.layer.shadowOffset = CGSizeMake(0,0);//shadowOffset阴影偏移，默认(0, -3),这个跟shadowRadius配合使用
    _boardView.layer.shadowOpacity = 0.7;//阴影透明度，默认0
    _boardView.layer.shadowRadius = 10;//阴影半径，默认3
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
            [line addObject:gl];
        }
        [arr addObject:line];
    }
    self.gridLayer = [NSArray arrayWithArray:arr];
    self.nextChessImage.image = self.model.goBoard.nextChessType == ChessTypeBlack ? [UIImage imageNamed:@"black"] :[UIImage imageNamed:@"white"];
    
    _avPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"play" ofType:@"mp3"]] error:nil];//使用本地URL创建
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
//    for (UITouch *touch in allTouches) {
//        if ([touch.view isKindOfClass:[BoardView class]]) {
//            _handLayer.hidden = NO;
//            BoardView *v = (BoardView*)touch.view;
//            CGPoint point = [touch locationInView:v]; //返回触摸点在视图中的当前坐标
//            [CATransaction begin];
//            ///关闭隐式动画
//            [CATransaction setDisableActions:YES];
//            _handLayer.position = point;
//            [CATransaction commit];
//            if (_model.goBoard.nextChessType == ChessTypeBlack) {
//                _handLayer.contents = (id)[UIImage imageNamed:@"black"].CGImage;
//            }else{
//                _handLayer.contents = (id)[UIImage imageNamed:@"white"].CGImage;
//            }
//        }
//    }
//}

//-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
//    for (UITouch *touch in allTouches) {
//        if ([touch.view isKindOfClass:[BoardView class]]) {
//            BoardView *v = (BoardView*)touch.view;
//            CGPoint point = [touch locationInView:v]; //返回触摸点在视图中的当前坐标
//            if ([v.layer containsPoint:point]) {
//                [CATransaction begin];
//                ///关闭隐式动画
//                [CATransaction setDisableActions:YES];
//                _handLayer.position = point;
//                [CATransaction commit];
//            }else{
//                _handLayer.hidden = YES;
//            }
//            
//
//        }
//    }
//}

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
                ChessType chessType = _model.goBoard.nextChessType;
                NSArray* eats = nil;
                if ([_model.goBoard playAtLine:ll.line andCol:ll.col withEatChesses:&eats]) {
                    [_avPlayer play];
                    if (chessType == ChessTypeBlack) {
                        ll.contents = (id)[UIImage imageNamed:@"black"].CGImage;
                    }else{
                        ll.contents = (id)[UIImage imageNamed:@"white"].CGImage;
                    }
                    if (eats!=nil) {
                        for (GoPoint* g in eats) {
                            GridLayer* gl = self.gridLayer[g.line][g.col];
                            gl.contents = nil;
                        }
                    }
                    self.nextChessImage.image = self.model.goBoard.nextChessType == ChessTypeBlack ? [UIImage imageNamed:@"black"] :[UIImage imageNamed:@"white"];
                }
                
            }
        }
    }
}
@end

