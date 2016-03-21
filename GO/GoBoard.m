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
                [line addObject:[GoGrid gridWithPoint:[GoPoint pointWithLine:i andCol:j andChessType:ChessTypeNull]]];
            }
            [arr addObject:line];
        }
        _boardModel = [NSArray arrayWithArray:arr];
        _nextChessType = ChessTypeBlack;
        _eats = [NSMutableArray array];
        _steps = [NSMutableArray array];
        _robs = [NSMutableArray array];
    }
    return self;
}

-(void)restart{
    for (NSArray* line in _boardModel) {
        for (GoGrid* grid in line) {
            grid.status = GridStatusEmpty;
            grid.chess = ChessTypeNull;
            grid.checkflg = 0;
        }
    }
    _nextChessType = ChessTypeBlack;
    [_robs removeAllObjects];
    [_eats removeAllObjects];
    [_steps removeAllObjects];
}

//计算属性
-(NSInteger)stepCount{
    return [_steps count];
}

-(BOOL)playAtLine:(int)line andCol:(int)col withEatChesses:(NSArray *__autoreleasing *)eatChesses{
    BOOL result = NO;
    GoGrid *g = _boardModel[line][col];
    if (g) {
        if (g.status == GridStatusEmpty) {
            g.chess = self.nextChessType;
            self.nextChessType = (self.nextChessType == ChessTypeBlack)?ChessTypeWhite:ChessTypeBlack;
            g.status = GridStatusFull;
            [_steps addObject:[GoPoint pointWithLine:line andCol:col andChessType:g.chess]];
            result = YES;
            NSInteger checkFlg = [_steps count];
            
            //检查提子
            ChessType type = (g.chess == ChessTypeWhite)?ChessTypeBlack:ChessTypeWhite;
            NSArray* arr = [self findChessAround:g withCheckFlag:checkFlg whichIsSameChessType:type];
            NSMutableArray* resultArray = [NSMutableArray array];
            
            for (GoGrid *grid in arr) {
                if (![resultArray containsObject:grid]) {
                    NSArray *ta =[self checkEatFromGrid:grid withCheckFlag:checkFlg];
                    [resultArray addObjectsFromArray:ta];
                }

            }
            if ([resultArray count]==0) {
                [resultArray addObjectsFromArray:[self checkEatFromGrid:g withCheckFlag:checkFlg]];
            }
            //解除劫的锁定
            if (self.rob) {
                [self.robs addObject:[GoPoint pointWithLine:self.rob.point.line andCol:self.rob.point.col andChessType:self.rob.point.chessType]];
                self.rob.status = GridStatusEmpty;
                self.rob = nil;
            }else{
                [self.robs addObject:[GoPoint pointWithLine:-1 andCol:-1 andChessType:ChessTypeNull]];
            }
            
            NSMutableArray *ea = [NSMutableArray array];
            if ([resultArray count]==1 && ((GoGrid*)resultArray[0]).chess != g.chess) {//检查劫
                GoGrid* gg = (GoGrid*)resultArray[0];
                [ea addObject:[GoPoint pointWithLine:gg.point.line andCol:gg.point.col andChessType:gg.point.chessType]];
                gg.chess = ChessTypeNull;
                gg.status = GridStatusUnAvailable;
                self.rob = gg;

                
            }else if([resultArray count]>0){
                for (GoGrid* gg in resultArray) {
                    [ea addObject:[GoPoint pointWithLine:gg.point.line andCol:gg.point.col andChessType:gg.point.chessType]];
                    gg.chess = ChessTypeNull;
                    gg.status = GridStatusEmpty;

                }
            }
            *eatChesses = [NSArray arrayWithArray:ea];
            [_eats addObject:*eatChesses];
            NSLog(@"%ld",resultArray.count);
            
        }
    }
    
    return result;
}

-(NSArray*)findChessAround:(GoGrid*)grid withCheckFlag:(NSInteger)checkFlg whichIsSameChessType:(ChessType)type{
    NSMutableArray* arr = [NSMutableArray array];
    if (grid.point.line>0 ) {
        GoGrid *g = _boardModel[grid.point.line-1][grid.point.col];
        if (g.chess==type && g.checkflg!=checkFlg) {
            [arr addObject:g];
        }
    }
    if (grid.point.line<(_lineCount-1)) {
        GoGrid *g = _boardModel[grid.point.line+1][grid.point.col];
        if (g.chess==type && g.checkflg!=checkFlg) {
            [arr addObject:g];
        }
    }
    if (grid.point.col>0) {
        GoGrid *g = _boardModel[grid.point.line][grid.point.col-1];
        if (g.chess==type && g.checkflg!=checkFlg) {
            [arr addObject:g];
        }
    }
    if (grid.point.col<(_colCount-1)) {
        GoGrid *g = _boardModel[grid.point.line][grid.point.col+1];
        if (g.chess==type && g.checkflg!=checkFlg) {
            [arr addObject:g];
        }
    }
    
    return arr;
}

-(BOOL)hasAir:(GoGrid*)grid{
    BOOL result = NO;
    if (grid.point.line>0 && !result) {
        GoGrid *g = _boardModel[grid.point.line-1][grid.point.col];
        if(g.status != GridStatusFull){
            result = YES;
        }
    }
    if (grid.point.line<(_lineCount-1) && !result) {
        GoGrid *g = _boardModel[grid.point.line+1][grid.point.col];
        if(g.status != GridStatusFull){
            result = YES;
        }    }
    if (grid.point.col>0 && !result) {
        GoGrid *g = _boardModel[grid.point.line][grid.point.col-1];
        if(g.status != GridStatusFull){
            result = YES;
        }
    }
    if (grid.point.col<(_colCount-1) && !result) {
        GoGrid *g = _boardModel[grid.point.line][grid.point.col+1];
        if(g.status != GridStatusFull){
            result = YES;
        }
    }
    return  result;
}

-(NSArray*)checkEatFromGrid:(GoGrid*)grid withCheckFlag:(NSInteger)checkFlg{
    NSMutableArray *eatChesses = [NSMutableArray array];
    if (grid.chess != ChessTypeNull && grid.checkflg!=checkFlg) {
        grid.checkflg = checkFlg;
        if (![self hasAir:grid]) {
            [eatChesses addObject:grid];
            NSArray *arround = [self findChessAround:grid withCheckFlag:checkFlg whichIsSameChessType:grid.chess];
            for (GoGrid* g in arround) {
                if (g.checkflg != checkFlg) {
                    NSArray *tmpEat = [self checkEatFromGrid:g withCheckFlag:checkFlg];
                    if (tmpEat==nil || tmpEat.count==0) {
                        [eatChesses removeAllObjects];
                        break;
                    }else{
                        [eatChesses addObjectsFromArray:tmpEat];
                    }
                }

            }
        }
    }
    return eatChesses;
}

-(GoPoint *)doBackWithEatChesses:(NSArray *__autoreleasing *)eatChesses{
    
    //先放吃子
    *eatChesses = [_eats lastObject];
    [_eats removeLastObject];
    for (GoPoint* gp in *eatChesses) {
        GoGrid* g = _boardModel[gp.line][gp.col];
        g.status = GridStatusFull;
        g.chess = gp.chessType;
        g.checkflg = 0;
    }
    
    //再拿落在
    GoPoint* step = [_steps lastObject];
    GoGrid* g = _boardModel[step.line][step.col];
    _nextChessType = g.chess;
    g.status = GridStatusEmpty;
    g.chess = ChessTypeNull;
    g.checkflg = 0;
    [_steps removeLastObject];
    
    //
    
    GoPoint* p = [_robs lastObject];
    if (p.line>=0 && p.col>=0) {
        GoGrid* g = _boardModel[p.line][p.col];
        g.status = GridStatusUnAvailable;
        g.checkflg = 0;
        g.chess = ChessTypeNull;
        self.rob = g;
    }else{
        self.rob = nil;
    }
    [_robs removeLastObject];
    return step;
}

@end


@implementation GoPoint

+(instancetype)pointWithLine:(int)line andCol:(int)col andChessType:(ChessType)chessType{
    GoPoint *p = [[GoPoint alloc] init];
    p.line = line;
    p.col = col;
    p.chessType = chessType;
    return p;
}

@end