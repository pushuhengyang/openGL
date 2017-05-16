//
//  ViewController.m
//  13 -demo视频绘制
//
//  Created by xuwenhao on 17/5/11.
//  Copyright © 2017年 Hiniu. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "VBHView.h"
#import <MobileCoreServices/MobileCoreServices.h>

# define ONE_FRAME_DURATION 0.03
# define LUMA_SLIDER_TAG 0
# define CHROMA_SLIDER_TAG 1

static void *AVPlayerItemStatusContext = &AVPlayerItemStatusContext;

@interface ViewController ()<AVPlayerItemOutputPullDelegate>

{
    AVPlayer *_player;
    AVPlayerItemVideoOutput *_videoOutPut;//一个输出流
    CADisplayLink *_displayLink;
    id _timeObserver;//进度监听者  暂时不用
    dispatch_queue_t _myVideoOutputQueue;

}

@property(strong,nonatomic)VBHView *vbView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    NSDictionary *pixBuffAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)};
    _videoOutPut = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixBuffAttributes];
    _myVideoOutputQueue = dispatch_queue_create("myVideoOutputQueue", DISPATCH_QUEUE_SERIAL);
    [_videoOutPut setDelegate:self queue:_myVideoOutputQueue];
    
    
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"abc" ofType:@"mp4"]]];
    [item addOutput:_videoOutPut];
    _player = [[AVPlayer alloc]initWithPlayerItem:item];
    [_player play];
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displaylinkCallBack:)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_displayLink setPaused:NO];

    [self.view addSubview:self.vbView];
    
}




-(VBHView *)vbView{
    if (!_vbView) {
        _vbView = [VBHView new];
        _vbView.frame  =[UIScreen mainScreen].bounds;
        [_vbView setupGL];
    }
    return _vbView;
}


-(void)displaylinkCallBack:(CADisplayLink *)sender{
    CMTime optputTime = kCMTimeInvalid;
    CFTimeInterval nextVSync = ([sender timestamp] + [sender duration]);
    optputTime = [_videoOutPut itemTimeForHostTime:nextVSync];
    if ([_videoOutPut hasNewPixelBufferForItemTime:optputTime]){
        CVPixelBufferRef pixBuffer = NULL;
        pixBuffer = [_videoOutPut copyPixelBufferForItemTime:optputTime itemTimeForDisplay:NULL];
        
        [_vbView displayPixelBuffer:pixBuffer];
        
        if (pixBuffer!=NULL) {
            CFRelease(pixBuffer);
        }
    }
}


- (void)outputMediaDataWillChange:(AVPlayerItemOutput *)sender
{
    // Restart display link.
    [_displayLink setPaused:NO];
}






@end
