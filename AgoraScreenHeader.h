//
//  TransferVideo.h
//  AgoraShareSrceen
//
//  Created by LEB on 2021/6/9.
//

#ifndef AgoraReplayKit_h
#define AgoraReplayKit_h

#import <ReplayKit/ReplayKit.h>

#define AGORA_REPLAYKIT_SERVER_PORT 12090

#define AGORA_REPLAYKIT_MAGIC_NUMBER 0x12345678

#define AGORA_REPLAYKIT_SOURCE_COMPILE

#ifdef AGORA_REPLAYKIT_SOURCE_COMPILE

#import "AgoraRtcEngineKit.h"
#include "ahpl_log.h"

#define AgoraLogInternal(LOGLEVEL, PREFIX, FORMAT, ...)                                          \
  @autoreleasepool {                                                                             \
    NSString* __log_message = [[NSString alloc]                                                  \
        initWithFormat:@"%@%@", PREFIX, [NSString stringWithFormat:FORMAT, ##__VA_ARGS__, nil]]; \
    ahpl_log(LOGLEVEL, __log_message.UTF8String);                                                \
  }

#define AgoraErrorLog(FORMAT, ...) \
  AgoraLogInternal(0x0004, @"[AgoraReplayKit]", FORMAT, ##__VA_ARGS__);
#define AgoraWarnLog(FORMAT, ...) \
  AgoraLogInternal(0x0002, @"[AgoraReplayKit]", FORMAT, ##__VA_ARGS__);
#define AgoraInfoLog(FORMAT, ...) \
  AgoraLogInternal(0x0001, @"[AgoraReplayKit]", FORMAT, ##__VA_ARGS__);
#define AgoraDebugLog(FORMAT, ...) \
  AgoraLogInternal(0x0800, @"[AgoraReplayKit]", FORMAT, ##__VA_ARGS__);

#else

//#import <AgoraRtcKit/AgoraRtcEngineKit.h>
#import "/Users/leb/Project/SDK/Carbon/media_sdk3/include/api/exported/objc/AgoraRtcEngineKit.h"
#import "AgoraRtcEngineKit.h"


#define AgoraErrorLog(fmt, ...) NSLog((@"ERROR " fmt), ##__VA_ARGS__);
#define AgoraWarnLog(fmt, ...) NSLog((@"WARN " fmt), ##__VA_ARGS__);
#define AgoraInfoLog(fmt, ...) NSLog((@"INFO " fmt), ##__VA_ARGS__);
#define AgoraDebugLog(fmt, ...) NSLog((@"DEBUG " fmt), ##__VA_ARGS__);

#endif

typedef enum : size_t {
  AgoraReplayKitExtVideo = 1,
  AgoraReplayKitExtAudio = 2,
  AgoraReplayKitExtAudioMic = 3,
} AgoraReplayKitExtType;

typedef struct AgoraReplayKitTransport {
    
  int64_t magic;
  int8_t  ver;
  int64_t length;
  int64_t timestamp;
  AgoraReplayKitExtType type;

  size_t rotation;
  size_t stride;
  size_t width;
  size_t height;
  size_t left;
  size_t right;
  size_t top;
  size_t bottom;
  AgoraVideoPixelFormat format;
  
  size_t sampleRate;
  size_t channels;
  size_t bytesPerSample;

} AgoraReplayKitTransport;

typedef enum : int8_t {

  AgoraReplayKitMessageInvalid = 0,
  AgoraReplayKitMessageStart = 1,
  AgoraReplayKitMessageStop = 2,
  AgoraReplayKitMessagePause = 3,
  AgoraReplayKitMessageResume = 4,
  AgoraReplayKitMessageUpdate = 5,

} AgoraReplayKitMessageType;

typedef struct AgoraReplayKitMessage {
  AgoraReplayKitMessageType msgType;
  int8_t captureAudio;
  int8_t captureVideo;
  int8_t frameRate;
  int8_t captureStatusBar;
} AgoraReplayKitMessage;

#endif /* AgoraReplayKitEx */
