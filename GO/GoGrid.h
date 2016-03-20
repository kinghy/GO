//
//  GoGrid.h
//  GO
//
//  Created by  rjt on 16/3/18.
//  Copyright © 2016年 JYZD. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "GoDef.h"
#import "GoBoard.h"

@interface GoGrid : NSObject
@property (nonatomic) GridStatus status;
@property (nonatomic) ChessType chess;
@property (nonatomic,strong) GoPoint* point;
@property NSInteger checkflg;//检查标志位

+(instancetype)gridWithPoint:(GoPoint*)point;
@end
