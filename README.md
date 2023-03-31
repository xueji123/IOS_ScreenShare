# IOS_ScreenShare
4.x
# AgoraShareSrceen
#### 将sdk framework 拖入到AgoraRtcSdk/libs 中，pod install 即可（包含AgoraReplayKitExtension.framework）
#### MainViewController.mm 中填入appid 和 测试频道名channelname
#### demo 中包含摄像头与屏幕共享流之前的切换，和摄像头与屏幕共享流同时push的场景
#### 简单集成步骤说明：
* 新建replaykit 的target：Broadcast Upload Extension，具体步骤见：https://docs.agora.io/cn/Interactive%20Broadcast/screensharing_ios?platform=iOS
* 系统生成的SampleHandler.h继承AgoraReplayKitHandler，删除SampleHandler.m中所有系统自动实现的方法
* 主App中通过captureVideo 和captureAudio来控制屏幕共享是否采集视频和音频
* rtcEngineKit startScreenCapture 和 stopScreenCapture 即可
