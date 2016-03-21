//
//  GoGrid.m
//  GO
//
//  Created by  rjt on 16/3/18.
//  Copyright © 2016年 JYZD. All rights reserved.
//

#import "GoGrid.h"

@implementation GoGrid
+(instancetype)gridWithPoint:(GoPoint *)point{
    GoGrid *g = [[GoGrid alloc] init];
    g.point = point;
    return g;
}

-(void)setChess:(ChessType)chess{
    _chess = chess;
    _point.chessType = chess;
}

@end
