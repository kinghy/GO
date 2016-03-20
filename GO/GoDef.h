//
//  GoDef.h
//  GO
//
//  Created by kinghy on 16/3/19.
//  Copyright © 2016年 JYZD. All rights reserved.
//

#ifndef GoDef_h
#define GoDef_h
typedef enum : NSUInteger {
    GridStatusEmpty,
    GridStatusUnAvailable,
    GridStatusFull,
} GridStatus;

typedef enum : NSUInteger {
    ChessTypeNull,
    ChessTypeWhite,
    ChessTypeBlack
} ChessType;

#endif /* GoDef_h */
