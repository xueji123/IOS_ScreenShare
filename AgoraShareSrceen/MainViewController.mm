//
//  ViewController.m
//  AgoraShareSrceen
//
//  Created by ZH on 2022/5/31.
//

#import "MainViewController.h"
#import <AVKit/AVKit.h>
#import <ReplayKit/ReplayKit.h>
#import <AgoraRtcKit/AgoraRtcKit.h>
#import <AgoraReplayKitExtension/AgoraReplayKitExtension.h>

//#error "请输入localAppId"
static NSString *localAppId = @""; //需要自己的appid
//#error "请输入kChannelName"
static NSString *kChannelName = @"test";

@interface MainViewController () <AgoraRtcEngineDelegate>

@property (strong, nonatomic) RPSystemBroadcastPickerView *broadPickerView API_AVAILABLE(ios(12.0));
@property (strong, nonatomic) AgoraRtcEngineKit *rtcEngineKit;
@property (strong, nonatomic) UIView *localView;
@property (strong, nonatomic) UIButton *screenButton;
// 多频道共享
@property (strong, nonatomic) UIButton *multiButton;
@property (strong, nonatomic) AgoraRtcConnection *connection;
@property (assign, nonatomic) BOOL isMultiChannel;

@end

@implementation MainViewController

- (AgoraRtcEngineKit *)rtcEngineKit {
    
    if (!_rtcEngineKit) {
        AgoraRtcEngineConfig *config = [[AgoraRtcEngineConfig alloc] init];
        config.appId = localAppId;
        config.audioScenario = AgoraAudioScenarioGameStreaming;
        config.channelProfile = AgoraChannelProfileLiveBroadcasting;
        _rtcEngineKit = [AgoraRtcEngineKit sharedEngineWithConfig:config delegate:self];
        [_rtcEngineKit enableVideo];
        [_rtcEngineKit enableAudio];
    }
    return _rtcEngineKit;
    
}

- (RPSystemBroadcastPickerView *)broadPickerView {
    CGRect frame = CGRectMake(UIScreen.mainScreen.bounds.size.width/2.0-50,UIScreen.mainScreen.bounds.size.height/2.0+200,100,100);
    if (!_broadPickerView) {
        _broadPickerView = [[RPSystemBroadcastPickerView alloc] initWithFrame:frame];
        _broadPickerView.preferredExtension = @"io.agora.AgoraShareSrceen.Broadcast";
        _broadPickerView.showsMicrophoneButton = NO;
        _broadPickerView.hidden = NO;
        [self.view addSubview:_broadPickerView];
    }
    return _broadPickerView;
}

- (UIButton *)screenButton {
    if (!_screenButton) {
        _screenButton = [[UIButton alloc] init];
        [_screenButton setTitle:@"开始共享" forState:UIControlStateNormal];
        [_screenButton addTarget:self action:@selector(shareScreen:) forControlEvents:UIControlEventTouchUpInside];
        [_screenButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _screenButton.frame = CGRectMake(UIScreen.mainScreen.bounds.size.width/2.0 - 100, UIScreen.mainScreen.bounds.size.height/2.0 + 100, 200, 40);
        [_screenButton setBackgroundColor:[UIColor colorWithRed:33.f/255.f green:150.f/255.f blue:243.f/255.f alpha:1]];
        _screenButton.selected = YES;
    }
    return _screenButton;
}

- (UIButton *)multiButton {
    if (!_multiButton) {
        _multiButton = [[UIButton alloc] init];
        [_multiButton setTitle:@"多频道共享" forState:UIControlStateNormal];
        [_multiButton addTarget:self action:@selector(multiScreen:) forControlEvents:UIControlEventTouchUpInside];
        [_multiButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _multiButton.frame = CGRectMake(UIScreen.mainScreen.bounds.size.width/2.0 - 100, UIScreen.mainScreen.bounds.size.height/2.0 + 200, 200, 40);
        [_multiButton setBackgroundColor:[UIColor colorWithRed:33.f/255.f green:150.f/255.f blue:243.f/255.f alpha:1]];
        _multiButton.selected = YES;
    }
    return _multiButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.localView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height/2.0)];
    [self.view addSubview:self.localView];
    [self.view addSubview:self.screenButton];
    [self.view addSubview:self.multiButton];
    AgoraRtcVideoCanvas *canvas = [AgoraRtcVideoCanvas new];
    canvas.view = self.localView;
    canvas.renderMode = AgoraVideoRenderModeFit;
    canvas.sourceType = AgoraVideoSourceTypeCamera;
    [self.rtcEngineKit setupLocalVideo:canvas];
    [self.rtcEngineKit startPreview];
    [self.rtcEngineKit setClientRole:AgoraClientRoleBroadcaster];
    
    [self.rtcEngineKit joinChannelByToken:nil
                             channelId:kChannelName
                                  info:nil
                                   uid:0
                           joinSuccess:^(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed) {
        
        [self.rtcEngineKit muteRemoteAudioStream:(1) mute:(true)];

        NSLog(@"joinChannelByToken uid:%@, channel:%@", @(uid), channel);

    }];
    
    
    AgoraRtcConnection *con = [[AgoraRtcConnection alloc] init];
    con.channelId = kChannelName;
    con.localUid = 1;
    self.connection = con;
}

- (void)shareScreen:(UIButton *)btn {
    self.isMultiChannel = NO;
    if (btn.isSelected) {
        AgoraScreenCaptureParameters2 *parameters = [AgoraScreenCaptureParameters2 new];
        parameters.captureVideo = YES;
        parameters.captureAudio = YES;
        parameters.audioParams = [AgoraScreenAudioParameters new];
        parameters.audioParams.captureSignalVolume = 50;
        [self.rtcEngineKit startScreenCapture:parameters];
        [self.screenButton setTitle:@"停止共享" forState:UIControlStateNormal];
        
    } else {
        [self.rtcEngineKit stopScreenCapture];
        [self.screenButton setTitle:@"开始共享" forState:UIControlStateNormal];
    }
    self.broadPickerView.center = self.multiButton.center;
    self.broadPickerView.hidden = !btn.selected;
    self.multiButton.hidden = btn.selected;
    btn.selected = !btn.isSelected;
}

- (void)multiScreen:(UIButton *)btn {
    self.isMultiChannel = YES;
    if (btn.isSelected) {
        AgoraScreenCaptureParameters2 *parameters = [AgoraScreenCaptureParameters2 new];
        parameters.captureVideo = YES;
        parameters.captureAudio = YES;
        parameters.audioParams = [AgoraScreenAudioParameters new];
        parameters.audioParams.captureSignalVolume = 100;
        [self.rtcEngineKit startScreenCapture:parameters];
        [self.multiButton setTitle:@"停止多频道共享" forState:UIControlStateNormal];
    } else {
        [self.rtcEngineKit stopScreenCapture];
        [self.rtcEngineKit leaveChannelEx:self.connection leaveChannelBlock:nil];
        [self.multiButton setTitle:@"多频道共享" forState:UIControlStateNormal];
    }
    self.broadPickerView.center = self.screenButton.center;
    self.broadPickerView.hidden = !btn.selected;
    self.screenButton.hidden = btn.selected;
    btn.selected = !btn.isSelected;
}

#pragma mark - AgoraRtcEngineDelegate

- (void)rtcEngine:(AgoraRtcEngineKit* _Nonnull)engine didOccurError:(AgoraErrorCode)errorCode {
    NSLog(@"%@ errorCode:%@", NSStringFromSelector(_cmd), @(errorCode));
}

- (void)rtcEngine:(AgoraRtcEngineKit* _Nonnull)engine didApiCallExecute:(NSInteger)error api:(NSString* _Nonnull)api result:(NSString* _Nonnull)result {
    NSLog(@"didApiCallExecute:%@ api:%@ result:%@", @(error), api, result);
}

- (void)rtcEngine:(AgoraRtcEngineKit* _Nonnull)engine didOccurWarning:(AgoraWarningCode)warningCode {
    NSLog(@"%@ warningCode:%@", NSStringFromSelector(_cmd), @(warningCode));
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine localVideoStateChangedOfState:(AgoraVideoLocalState)state error:(AgoraLocalVideoStreamError)error sourceType:(AgoraVideoSourceType)sourceType {
    NSLog(@"%@ sourceType:%@ state:%@ error:%@", NSStringFromSelector(_cmd), @(sourceType), @(state), @(error));
    if(sourceType != AgoraVideoSourceTypeScreen) {
        return;
    }
    
    if (state == AgoraVideoLocalStateCapturing) {
        // 多频道共享(双路)
        if (self.isMultiChannel) {
            AgoraRtcChannelMediaOptions *option = [[AgoraRtcChannelMediaOptions alloc] init];
            option.clientRoleType = AgoraClientRoleBroadcaster;
            option.publishScreenCaptureVideo = YES;
            option.publishScreenCaptureAudio = YES;
            option.autoSubscribeVideo = NO;
            option.autoSubscribeAudio = NO;
            [self.rtcEngineKit joinChannelExByToken:nil connection:self.connection delegate:self mediaOptions:option joinSuccess:nil];
        } else { // 单频道共享
            AgoraRtcChannelMediaOptions *option = [[AgoraRtcChannelMediaOptions alloc] init];
            option.clientRoleType = AgoraClientRoleBroadcaster;
            option.publishCameraTrack = NO;
            option.publishScreenCaptureVideo = YES;
            option.publishScreenCaptureAudio = YES;
            [self.rtcEngineKit updateChannelWithMediaOptions:option];
        }
    }
    
    if(state == AgoraVideoLocalStateStopped) {
        _broadPickerView.hidden = YES;
        // 多频道共享(双路)
        if (self.isMultiChannel) {
            [self.rtcEngineKit leaveChannelEx:self.connection leaveChannelBlock:nil];
            [self.multiButton setTitle:@"多频道共享" forState:UIControlStateNormal];
            self.screenButton.hidden = NO;
            self.multiButton.selected = YES;
        } else { // 单频道共享
            AgoraRtcChannelMediaOptions *option = [[AgoraRtcChannelMediaOptions alloc] init];
            option.clientRoleType = AgoraClientRoleBroadcaster;
            option.publishCameraTrack = YES;
            option.publishScreenCaptureVideo = NO;
            option.publishScreenCaptureAudio = NO;
            [self.rtcEngineKit updateChannelWithMediaOptions:option];
            [self.screenButton setTitle:@"开始共享" forState:UIControlStateNormal];
            self.multiButton.hidden = NO;
            self.screenButton.selected = YES;
        }
    }
}

@end


