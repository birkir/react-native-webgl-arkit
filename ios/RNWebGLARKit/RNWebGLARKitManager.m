#import "RNWebGLARKitManager.h"
#import "RNWebGLARKit.h"
#import "UIKit/UIKit.h"

@implementation RNWebGLARKitManager

RCT_EXPORT_MODULE()

- (UIView *)view {
    return [RNWebGLARKit sharedInstance];
}

RCT_EXPORT_VIEW_PROPERTY(debug, BOOL)
RCT_EXPORT_VIEW_PROPERTY(planeDetection, BOOL)
RCT_EXPORT_VIEW_PROPERTY(lightEstimation, BOOL)
RCT_EXPORT_VIEW_PROPERTY(worldAlignment, NSInteger)
RCT_EXPORT_VIEW_PROPERTY(onPlaneDetected, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPlaneUpdated, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPlaneRemoved, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onFrameUpdate, RCTBubblingEventBlock)

RCT_EXPORT_METHOD(pause:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
    [[RNWebGLARKit sharedInstance] pause];
    resolve(@{});
}

RCT_EXPORT_METHOD(resume:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
    [[RNWebGLARKit sharedInstance] resume];
    resolve(@{});
}

RCT_EXPORT_METHOD(reset:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
    [[RNWebGLARKit sharedInstance] reset];
    resolve(@{});
}

@end
