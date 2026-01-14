#import <Foundation/Foundation.h>  
#import <AVFoundation/AVFoundation.h>  
  
static BOOL YTMU(NSString *key) {  
    NSDictionary *YTMUltimateDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"];  
    return [YTMUltimateDict[key] boolValue];  
}  
  
@interface YTMWatchView: UIView  
@property (nonatomic, strong) AVAudioEngine *audioEngine;  
@property (nonatomic, strong) AVAudioUnitEQ *equalizer;  
@end  
  
%hook YTMWatchView  
- (instancetype)initWithColorScheme:(id)scheme {  
    self = %orig;  
    if (self && YTMU(@"YTMUltimateIsEnabled") && YTMU(@"equalizerEnabled")) {  
        [self setupEqualizer];  
    }  
    return self;  
}  
  
%new  
- (void)setupEqualizer {  
    self.audioEngine = [[AVAudioEngine alloc] init];  
    self.equalizer = [[AVAudioUnitEQ alloc] initWithNumberOfBands:10];  
      
    // イコライザー設定の読み込み  
    NSDictionary *eqSettings = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"][@"equalizerBands"];  
    for (int i = 0; i < 10; i++) {  
        AVAudioUnitEQFilterParameters *params = self.equalizer.bands[i];  
        params.frequency = 32 * pow(2, i); // 32Hz to 16kHz  
        params.gain = [eqSettings[@(i)] floatValue];  
        params.bandwidth = 1.0;  
        params.filterType = AVAudioUnitEQFilterTypeParametric;  
    }  
      
    [self.audioEngine attachNode:self.equalizer];  
}  
%end
