//
//  GoBoard.h
//  GO
//
//  Created by  rjt on 16/3/18.
//  Copyright © 2016年 JYZD. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kStdLineCount 19
#define kStdColCount 19

typedef enum : NSUInteger {
    ChessTypeWhite,
    ChessTypeBlack
} ChessType;



@interface GoBoard : NSObject
/*!
 *  @brief 默认创建19*19的标准围棋盘
 *
 *  @return 实例
 */
+(instancetype)board;

//棋盘二维数组
@property (nonatomic,strong)NSArray *boardModel;

@property int lineCount;//行数
@property int colCount;//列数

@property ChessType nextChessType;

@end
