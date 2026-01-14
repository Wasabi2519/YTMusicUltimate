#import "EqualizerSettingsController.h"  
#import <AVFoundation/AVFoundation.h>  
  
@interface EqualizerSettingsController ()  
@property (nonatomic, strong) AVAudioUnitEQ *equalizer;  
@property (nonatomic, strong) NSArray<UISlider *> *bandSliders;  
@property (nonatomic, strong) UISegmentedControl *presetControl;  
@end  
  
@implementation EqualizerSettingsController  
  
- (void)viewDidLoad {  
    [super viewDidLoad];  
      
    self.title = LOC(@"EQUALIZER");  
    self.view.backgroundColor = [UIColor systemBackgroundColor];  
      
    [self setupNavigationBar];  
    [self setupPresetControl];  
    [self setupBandSliders];  
}  
  
- (void)setupNavigationBar {  
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone   
                                                                                target:self   
                                                                                action:@selector(doneButtonTapped)];  
    self.navigationItem.rightBarButtonItem = doneButton;  
}  
  
- (void)setupPresetControl {  
    self.presetControl = [[UISegmentedControl alloc] initWithItems:@[  
        LOC(@"FLAT"), LOC(@"ROCK"), LOC(@"POP"), LOC(@"JAZZ"), LOC(@"CLASSICAL")  
    ]];  
    self.presetControl.selectedSegmentIndex = 0;  
    [self.presetControl addTarget:self action:@selector(presetChanged:) forControlEvents:UIControlEventValueChanged];  
      
    [self.view addSubview:self.presetControl];  
    self.presetControl.translatesAutoresizingMaskIntoConstraints = NO;  
    [NSLayoutConstraint activateConstraints:@[  
        [self.presetControl.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],  
        [self.presetControl.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],  
        [self.presetControl.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20]  
    ]];  
}  
  
- (void)setupBandSliders {  
    NSMutableArray *sliders = [NSMutableArray array];  
    UIView *previousView = self.presetControl;  
      
    NSArray *frequencies = @[@"32Hz", @"64Hz", @"125Hz", @"250Hz", @"500Hz",   
                             @"1kHz", @"2kHz", @"4kHz", @"8kHz", @"16kHz"];  
      
    for (int i = 0; i < 10; i++) {  
        UILabel *label = [[UILabel alloc] init];  
        label.text = frequencies[i];  
        label.textAlignment = NSTextAlignmentCenter;  
        [self.view addSubview:label];  
          
        UISlider *slider = [[UISlider alloc] init];  
        slider.minimumValue = -12.0;  
        slider.maximumValue = 12.0;  
        slider.value = self.equalizer.bands[i].gain;  
        slider.tag = i;  
        [slider addTarget:self action:@selector(bandValueChanged:) forControlEvents:UIControlEventValueChanged];  
        [self.view addSubview:slider];  
          
        label.translatesAutoresizingMaskIntoConstraints = NO;  
        slider.translatesAutoresizingMaskIntoConstraints = NO;  
          
        [NSLayoutConstraint activateConstraints:@[  
            [label.topAnchor constraintEqualToAnchor:previousView.bottomAnchor constant:20],  
            [label.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],  
            [label.widthAnchor constraintEqualToConstant:60],  
              
            [slider.centerYAnchor constraintEqualToAnchor:label.centerYAnchor],  
            [slider.leadingAnchor constraintEqualToAnchor:label.trailingAnchor constant:10],  
            [slider.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20]  
        ]];  
          
        [sliders addObject:slider];  
        previousView = label;  
    }  
      
    self.bandSliders = [sliders copy];  
}  
  
- (void)presetChanged:(UISegmentedControl *)sender {  
    NSArray *presets = @[  
        // Flat  
        @[@0, @0, @0, @0, @0, @0, @0, @0, @0, @0],  
        // Rock  
        @[@5, @4, @3, @1, @0, @-1, @1, @3, @4, @5],  
        // Pop  
        @[@-1, @2, @4, @4, @2, @0, @-1, @-1, @0, @0],  
        // Jazz  
        @[@3, @2, @1, @2, @-2, @0, @1, @2, @3, @3],  
        // Classical  
        @[@4, @3, @2, @0, @-2, @-2, @0, @2, @3, @4]  
    ];  
      
    NSArray *selectedPreset = presets[sender.selectedSegmentIndex];  
      
    for (int i = 0; i < 10; i++) {  
        float gain = [selectedPreset[i] floatValue];  
        self.equalizer.bands[i].gain = gain;  
        self.bandSliders[i].value = gain;  
    }  
      
    [self saveEqualizerSettings];  
}  
  
- (void)bandValueChanged:(UISlider *)sender {  
    int bandIndex = (int)sender.tag;  
    self.equalizer.bands[bandIndex].gain = sender.value;  
    [self saveEqualizerSettings];  
}  
  
- (void)saveEqualizerSettings {  
    NSMutableDictionary *eqSettings = [NSMutableDictionary dictionary];  
    for (int i = 0; i < 10; i++) {  
        eqSettings[@(i)] = @(self.equalizer.bands[i].gain);  
    }  
      
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];  
    NSMutableDictionary *YTMUltimateDict = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:@"YTMUltimate"]];  
    [YTMUltimateDict setObject:eqSettings forKey:@"equalizerBands"];  
    [defaults setObject:YTMUltimateDict forKey:@"YTMUltimate"];  
}  
  
- (void)doneButtonTapped {  
    [self dismissViewControllerAnimated:YES completion:nil];  
}  
  
@end
