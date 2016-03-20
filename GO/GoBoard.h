//
//  GoBoard.h
//  GO
//
//  Created by  rjt on 16/3/18.
//  Copyright © 2016年 JYZD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoDef.h"

#define kStdLineCount 19
#define kStdColCount 19

@class GoGrid;
@interface GoPoint : NSObject
@property int line;//行数
@property int col;//列数
+(instancetype)pointWithLine:(int)line andCol:(int)col;
@end


@interface GoBoard : NSObject
/*!
 *  @brief 默认创建19*19的标准围棋盘
 *
 *  @return 实例
 */
+(instancetype)board;

//棋盘二维数组
@property (nonatomic,strong)NSArray *boardModel;
@property (nonatomic,strong)GoGrid *rob;//记录打劫位置，下手解开

@property int lineCount;//行数
@property int colCount;//列数

@property ChessType nextChessType;
@property NSMutableArray* steps;

/**
 *  落子
 *
 *  @param line       行数
 *  @param col        列数
 *  @param eatChesses 返回吃子GoPoint队列
 *
 *  @return 是否可以落子
 */
-(BOOL)playAtLine:(int)line andCol:(int)col withEatChesses:(NSArray**)eatChesses;



@end
