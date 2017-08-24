//
//  AudioEncoding.m
//  IFlyTest
//
//  Created by Jake on 2017/8/15.
//  Copyright © 2017年 Jake. All rights reserved.
//

#import "AudioEncoding.h"
#include "lame.h"

@interface AudioEncoding()

@property (nonatomic,copy) NSString *cachePath;

@end

@implementation AudioEncoding

- (instancetype) init {
    
    self = [super init];
    if (self) {
        _cachePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    }
    return self;
}


- (BOOL) encodingPCMToMP3 {
    
    NSString *fileName = [NSString stringWithFormat:@"/%ld.mp3",time(NULL)];
    NSString *mp3filePath = [_cachePath stringByAppendingPathComponent:fileName];

    @try {
        int read, write;
        
        FILE *pcm = fopen([self.sourceFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                    //删除头，否则在前一秒钟会有杂音
        FILE *mp3 = fopen([mp3filePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = (int) fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        return NO;
    }
    @finally {
        _ouputFilePath = mp3filePath;
    }
    return YES;
}

@end
