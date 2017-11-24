//
//  ViewController.m
//  VKPlayerDemo
//
//  Created by jinyou on 2017/11/23.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) AVPlayerItem *myPlayerItem;
@property (nonatomic,strong) AVPlayerLayer *playerLayer;

@property (nonatomic,strong) UISlider *slider;
@property (nonatomic,assign) CGFloat duration;

//监控进度
@property (nonatomic,strong) NSTimer *avTimer;
@property (nonatomic,strong) UIButton *backButton;
@property (nonatomic,strong) UIButton *playButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initVideo];
    [self initUI];
}

- (void)initVideo
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSURL *sourceMovieUrl = [NSURL fileURLWithPath:self.filePath];
    
    AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:sourceMovieUrl options:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
    _duration = CMTimeGetSeconds(playerItem.asset.duration);
    
    _myPlayerItem = playerItem;
    _player = [AVPlayer playerWithPlayerItem:playerItem];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.videoGravity =AVLayerVideoGravityResizeAspect;
    
    [self.view.layer addSublayer:_playerLayer];
    
    [_player play];
    
    //监控播放进度
    self.avTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timer) userInfo:nil repeats:YES];
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoTouch:)];
    [self.view addGestureRecognizer:gesture];
    
    [self.player addObserver:self forKeyPath:@"status"options:NSKeyValueObservingOptionNew context:nil];
    // 监听status属性
    
    self.view.transform = CGAffineTransformMakeRotation(-M_PI / 2);
}

- (void)videoTouch:(UITapGestureRecognizer *)gesture
{
    if (gesture.numberOfTouches == 1) {
        
        if (self.backButton.isHidden == YES) {
            self.backButton.hidden = NO;
            self.playButton.hidden = NO;
            self.slider.hidden = NO;
        }else{
            self.backButton.hidden = YES;
            self.playButton.hidden = YES;
            self.slider.hidden = YES;
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object ==self.player && [keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey]integerValue];
    
        if (status == AVPlayerStatusReadyToPlay)
        {}
    }
}


//监控播放进度方法
- (void)timer
{
    self.slider.value = CMTimeGetSeconds(self.player.currentItem.currentTime) / CMTimeGetSeconds(self.player.currentItem.duration);
}

- (void)viewDidAppear:(BOOL)animated
{
    NSNumber *currentTime = [[NSUserDefaults standardUserDefaults] objectForKey:self.fileName];
    
    if (currentTime) {
        CGFloat floatTime = [currentTime floatValue];
        CMTime time = CMTimeMakeWithSeconds(_duration * floatTime, 1);
        [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        
        self.slider.value = floatTime;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.player pause];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.slider.value] forKey:self.fileName];
}

- (void)initUI
{
    self.slider = [[UISlider alloc] init];
    [self.slider addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.slider];
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton addTarget:self action:@selector(returnBack) forControlEvents:UIControlEventTouchUpInside];
    [self.backButton setTitle:@"返回" forState:UIControlStateNormal];
    [self.view addSubview:self.backButton];
    
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    [self.playButton setTitle:@"暂停" forState:UIControlStateNormal];
    [self.view addSubview:self.playButton];
}

- (void)play
{
    if (self.player.rate == 1.0) {
        [self.player pause];
        [self.playButton setTitle:@"播放" forState:UIControlStateNormal];
    }else{
        [self.player play];
        [self.playButton setTitle:@"暂停" forState:UIControlStateNormal];
    }
}

- (void)sliderChange:(UISlider *)slider
{
    CMTime time = CMTimeMakeWithSeconds(_duration * slider.value, 1);
    [_player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)returnBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillLayoutSubviews
{
    _playerLayer.frame = self.view.bounds;
    self.backButton.frame = CGRectMake(5, 10, 90, 50);
    self.playButton.frame = CGRectMake(10, self.view.bounds.size.height - 50, 70, 50);
    self.slider.frame = CGRectMake(80, self.view.bounds.size.height - 50, self.view.bounds.size.width - 85, 50);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
