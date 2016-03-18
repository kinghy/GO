//
//  ViewModel.m
//  GO
//
//  Created by  rjt on 16/3/18.
//  Copyright © 2016年 JYZD. All rights reserved.
//

#import "ViewModel.h"

@implementation ViewModel

-(instancetype)init{
    if (self = [super init]) {
        _goBoard = [GoBoard board];
    }
    return self;
}


@end
