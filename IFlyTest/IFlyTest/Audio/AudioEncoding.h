//
//  AudioEncoding.h
//  IFlyTest
//
//  Created by Jake on 2017/8/15.
//  Copyright © 2017年 Jake. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioEncoding : NSObject

@property (nonatomic,copy) NSString *sourceFilePath;
@property (nonatomic,copy,readonly) NSString *ouputFilePath;

- (BOOL) encodingPCMToMP3;

@end
