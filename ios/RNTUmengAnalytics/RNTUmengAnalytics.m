#import "RNTUmengAnalytics.h"

#import <UMCommon/UMConfigure.h>
#import <UMCommon/MobClick.h>

@implementation RNTUmengAnalytics

static NSString *CHANNEL = @"";

+ (void)init:(NSString *)appKey channel:(NSString *)channel debug:(BOOL)debug {

    CHANNEL = channel;
    
    [UMConfigure initWithAppkey:appKey channel:channel];
    [UMConfigure setLogEnabled:debug];

    // 手动采集
    [MobClick setAutoPageEnabled:NO];
    
}

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

- (dispatch_queue_t)methodQueue {
    return dispatch_queue_create("com.github.reactnativehero.umenganalytics", DISPATCH_QUEUE_SERIAL);
}

- (NSDictionary *)constantsToExport {
    return @{
        @"CHANNEL": CHANNEL,
    };
}

RCT_EXPORT_MODULE(RNTUmengAnalytics);

// 获得设备信息，用于集成测试
RCT_EXPORT_METHOD(getDeviceInfo:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {

    NSString *deviceId =[UMConfigure deviceIDForIntegration];
    
    resolve(@{
        @"deviceId": deviceId,
    });
    
}

// 账号统计
RCT_EXPORT_METHOD(signIn:(NSString *)userId provider:(NSString *)provider) {
    if (provider && provider.length > 0) {
        [MobClick profileSignInWithPUID:userId provider:provider];
    }
    else {
        [MobClick profileSignInWithPUID:userId];
    }
}

RCT_EXPORT_METHOD(signOut) {
    [MobClick profileSignOff];
}

RCT_EXPORT_METHOD(exitApp) {
    exit(0);
}

// 必须配对调用 beginLogPageView 和 endLogPageView 两个函数来完成自动统计
// 若只调用某一个函数不会生成有效数据
RCT_EXPORT_METHOD(enterPage:(NSString *)pageName) {
    [MobClick beginLogPageView:pageName];
}

RCT_EXPORT_METHOD(leavePage:(NSString *)pageName) {
    [MobClick endLogPageView:pageName];
}

// 自定义事件
RCT_EXPORT_METHOD(sendEvent:(NSString *)eventId) {
    [MobClick event:eventId];
}

RCT_EXPORT_METHOD(sendEventLabel:(NSString *)eventId label:(NSString *)label) {
    [MobClick event:eventId label:label];
}

RCT_EXPORT_METHOD(sendEventData:(NSString *)eventId data:(NSDictionary *)data) {
    [MobClick event:eventId attributes:data];
}

RCT_EXPORT_METHOD(sendEventCounter:(NSString *)eventId data:(NSDictionary *)data counter:(int)counter) {
    [MobClick event:eventId attributes:data counter:counter];
}

@end
