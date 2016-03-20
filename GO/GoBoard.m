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
                [line addObject:[GoGrid gridWithPoint:[GoPoint pointWithLine:i andCol:j]]];
            }
            [arr addObject:line];
        }
        _boardModel = [NSArray arrayWithArray:arr];
        _nextChessType = ChessTypeBlack;
        _steps = [NSMutableArray array];
    }
    return self;
}

-(BOOL)playAtLine:(int)line andCol:(int)col withEatChesses:(NSArray**)eatChesses{
    BOOL result = NO;
    GoGrid *g = _boardModel[line][col];
    if (g) {
        if (g.status == GridStatusEmpty) {
            g.chess = self.nextChessType;
            self.nextChessType = (self.nextChessType == ChessTypeBlack)?ChessTypeWhite:ChessTypeBlack;
            g.status = GridStatusFull;
            [_steps addObject:[GoPoint pointWithLine:line andCol:col]];
            result = YES;
            NSInteger checkFlg = [_steps count];
            
            //检查提子
            ChessType type = (g.chess == ChessTypeWhite)?ChessTypeBlack:ChessTypeWhite;
            NSArray* arr = [self findCheseAround:g withCheckFlag:checkFlg whichIsSameCheseType:type];
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
                self.rob.status = GridStatusEmpty;
                self.rob = nil;
            }
            
            NSMutableArray *ea = [NSMutableArray array];
            if ([resultArray count]==1 && ((GoGrid*)resultArray[0]).chess != g.chess) {//检查劫
                GoGrid* gg = (GoGrid*)resultArray[0];
                gg.chess = ChessTypeNull;
                gg.status = GridStatusUnAvailable;
                self.rob = gg;
                [ea addObject:gg.point];
                
            }else if([resultArray count]>0){
                for (GoGrid* gg in resultArray) {
                    gg.chess = ChessTypeNull;
                    gg.status = GridStatusEmpty;
                    [ea addObject:gg.point];
                }
            }
            *eatChesses = [NSArray arrayWithArray:ea];
            NSLog(@"%ld",resultArray.count);
            
        }
    }
    
    return result;
}

-(NSArray*)findCheseAround:(GoGrid*)grid withCheckFlag:(NSInteger)checkFlg whichIsSameCheseType:(ChessType)type{
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
            NSArray *arround = [self findCheseAround:grid withCheckFlag:checkFlg whichIsSameCheseType:grid.chess];
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


@end


@implementation GoPoint

+(instancetype)pointWithLine:(int)line andCol:(int)col{
    GoPoint *p = [[GoPoint alloc] init];
    p.line = line;
    p.col = col;
    return p;
}

@end