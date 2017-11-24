//
//  ViewController.m
//  VKPlayerDemo
//
//  Created by jinyou on 2017/11/23.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

typedef NS_ENUM(NSUInteger, Direction) {
    DirectionLeftOrRight,
    DirectionUpOrDown,
    DirectionNone
};

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

@property (assign, nonatomic) CGPoint startPoint;
@property (assign, nonatomic) CGFloat startVB;
@property (assign, nonatomic) Direction direction;

@property (strong, nonatomic) MPVolumeView *volumeView;//控制音量的view
@property (strong, nonatomic) UISlider* volumeViewSlider;//控制音量
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
    gesture.cancelsTouchesInView = NO;
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
    
    self.volumeView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * 9.0 / 16.0);
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

#pragma mark - 开始触摸
/*************************************************************************/
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:[touch view]];
    
    //记录首次触摸坐标
    self.startPoint = point;
    //检测用户是触摸屏幕的左边还是右边，以此判断用户是要调节音量还是亮度，左边是亮度，右边是音量
    if (self.startPoint.x <= screenHeight / 2.0) {
        //亮度
        self.startVB = [UIScreen mainScreen].brightness;
    } else {
        //音/量
        self.startVB = self.volumeViewSlider.value;
    }
    //方向置为无
    self.direction = DirectionNone;
    //记录当前视频播放的进度
    CMTime ctime = self.player.currentTime;
    //self.startVideoRate = ctime.value / ctime.timescale / self.total;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:[touch view]];
    
    //得出手指在Button上移动的距离
    CGPoint panPoint = CGPointMake(point.x - self.startPoint.x, point.y - self.startPoint.y);
    //分析出用户滑动的方向
    if (self.direction == DirectionNone) {
        if (panPoint.x >= 30 || panPoint.x <= -30) {
            //进度
            self.direction = DirectionLeftOrRight;
        } else if (panPoint.y >= 30 || panPoint.y <= -30) {
            //音量和亮度
            self.direction = DirectionUpOrDown;
        }
    }
    
    if (self.direction == DirectionNone) {
        return;
    } else if (self.direction == DirectionUpOrDown) {
        //音量和亮度
        if (self.startPoint.x <= screenHeight / 2.0) {
            //调节亮度
            if (panPoint.y < 0) {
                //增加亮度
                [[UIScreen mainScreen] setBrightness:self.startVB + (-panPoint.y / 30.0 / 10)];
            } else {
                //减少亮度
                [[UIScreen mainScreen] setBrightness:self.startVB - (panPoint.y / 30.0 / 10)];
            }
            
        } else {
            //音量
            if (panPoint.y < 0) {
                //增大音量
                [self.volumeViewSlider setValue:self.startVB + (-panPoint.y / 30.0 / 10) animated:YES];
                if (self.startVB + (-panPoint.y / 30 / 10) - self.volumeViewSlider.value >= 0.1) {
                    [self.volumeViewSlider setValue:0.1 animated:NO];
                    [self.volumeViewSlider setValue:self.startVB + (-panPoint.y / 30.0 / 10) animated:YES];
                }
                
            } else {
                //减少音量
                [self.volumeViewSlider setValue:self.startVB - (panPoint.y / 30.0 / 10) animated:YES];
            }
        }
    } else if (self.direction == DirectionLeftOrRight ) {
        //进度
        //        CGFloat rate = self.startVideoRate + (panPoint.x / 30.0 / 20.0);
        //        if (rate > 1) {
        //            rate = 1;
        //        } else if (rate < 0) {
        //            rate = 0;
        //        }
        //        self.currentRate = rate;
    }
}

#pragma mark - 结束触摸
- (void)touchesEndWithPoint:(CGPoint)point {
    if (self.direction == DirectionLeftOrRight) {
//        [self.player seekToTime:CMTimeMakeWithSeconds(self.total * self.currentRate, 1) completionHandler:^(BOOL finished) {
//            //在这里处理进度设置成功后的事情
//        }];
    }
}

- (MPVolumeView *)volumeView {
    if (_volumeView == nil) {
        _volumeView  = [[MPVolumeView alloc] init];
        [_volumeView sizeToFit];
        for (UIView *view in [_volumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                self.volumeViewSlider = (UISlider*)view;
                break;
            }
        }
    }
    return _volumeView;
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
