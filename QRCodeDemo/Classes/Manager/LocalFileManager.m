//
//  LocalFileManager.m
//  SeedSocial
//
//  Created by Admin on 15/5/5.
//  Copyright (c) 2015年 altamob. All rights reserved.
//

#import "LocalFileManager.h"

@implementation LocalFileManager

+ (instancetype)manager {
    static LocalFileManager *manager = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

@end
