#import <Foundation/Foundation.h>  
#import <AVFoundation/AVFoundation.h>  
  
static BOOL YTMU(NSString *key) {  
    NSDictionary *YTMUltimateDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"];  
    return [YTMUltimateDict[key] boolValue];  
}  
  
static int YTMUint(NSString *key) {  
    NSDictionary *YTMUltimateDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"];  
    return [YTMUltimateDict[key] integerValue];  
}  
  
@interface YTMWatchView: UIView  
@property (nonatomic, strong) AVAudioEngine *audioEngine;  
@property (nonatomic, strong) AVAudioUnitEQ *equalizer;  
@property (nonatomic, strong) UIButton *equalizerButton;  
@end  
  
%hook YTMWatchView  
%property (nonatomic, strong) AVAudioEngine *audioEngine;  
%property (nonatomic, strong) AVAudioUnitEQ *equalizer;  
%property (nonatomic, strong) UIButton *equalizerButton;  
  
- (instancetype)initWithColorScheme:(id)scheme {  
    self = %orig;  
    if (self && YTMU(@"YTMUltimateIsEnabled") && YTMU(@"equalizerEnabled")) {  
        [self setupEqualizer];  
        [self setupEqualizerButton];  
    }  
    return self;  
}  
  
%new  
- (void)setupEqualizer {  
    self.audioEngine = [[AVAudioEngine alloc] init];  
    self.equalizer = [[AVAudioUnitEQ alloc] initWithNumberOfBands:10];  
      
    // バンド設定の読み込み  
    NSDictionary *eqSettings = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"][@"equalizerBands"];  
    if (!eqSettings) {  
        // デフォルトプリセット  
        eqSettings = @{  
            @0: @0, @1: @0, @2: @0, @3: @0, @4: @0,  
            @5: @0, @6: @0, @7: @0, @8: @0, @9: @0  
        };  
    }  
      
    // 周波数帯域の設定  
    NSArray *frequencies = @[@32, @64, @125, @250, @500, @1000, @2000, @4000, @8000, @16000];  
      
    for (int i = 0; i < 10; i++) {  
        AVAudioUnitEQFilterParameters *params = self.equalizer.bands[i];  
        params.frequency = [frequencies[i] floatValue];  
        params.gain = [eqSettings[@(i)] floatValue];  
        params.bandwidth = 1.0;  
        params.filterType = AVAudioUnitEQFilterTypeParametric;  
        params.bypass = NO;  
    }  
      
    [self.audioEngine attachNode:self.equalizer];  
}  
  
%new  
- (void)setupEqualizerButton {  
    self.equalizerButton = [UIButton buttonWithType:UIButtonTypeSystem];  
    [self.equalizerButton setImage:[UIImage systemImageNamed:@"slider.horizontal.3"] forState:UIControlStateNormal];  
    [self.equalizerButton addTarget:self action:@selector(equalizerButtonTapped:) forControlEvents:UIControlEventTouchUpInside];  
    [self addSubview:self.equalizerButton];  
}  
  
%new  
- (void)equalizerButtonTapped:(UIButton *)sender {  
    // イコライザー設定画面を表示  
    EqualizerSettingsController *controller = [[EqualizerSettingsController alloc] init];  
    controller.equalizer = self.equalizer;  
      
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;  
    while (topController.presentedViewController) {  
        topController = topController.presentedViewController;  
    }  
      
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];  
    [topController presentViewController:navController animated:YES completion:nil];  
}  
  
- (void)layoutSubviews {  
    %orig;  
      
    if (YTMU(@"equalizerEnabled")) {  
        // イコライザーボタンの位置を調整  
        self.equalizerButton.frame = CGRectMake(50, CGRectGetHeight(self.frame) - 100, 44, 44);  
    }  
}  
%end
