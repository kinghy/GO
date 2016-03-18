//
//  GoBoard.m
//  GO
//
//  Created by  rjt on 16/3/18.
//  Copyright © 2016年 JYZD. All rights reserved.
//

#import "GoBoard.h"
#import "GoGrid.h"

@implementation GoBoard

+(instancetype)board{
    GoBoard* b = [[GoBoard alloc] init];
    return b;
}

-(instancetype)init{
    if (self=[super init]) {
        _colCount = kStdColCount;
        _lineCount = kStdLineCount;
        NSMutableArray* arr = [NSMutableArray array];
        for (int i=0; i<_lineCount; ++i) {
            NSMutableArray* line = [NSMutableArray array];
            for (int j=0; j<_colCount; ++j) {
                [line addObject:[[GoGrid alloc] init]];
            }
            [arr addObject:line];
        }
        _boardModel = [NSArray arrayWithArray:arr];
        _nextChessType = ChessTypeBlack;
    }
    return self;
}

@end
