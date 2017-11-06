#import "RNWebGLARKit.h"

@import CoreLocation;

@interface RNWebGLARKit () <ARSCNViewDelegate, ARSessionDelegate>

@property (nonatomic, strong) ARSession* session;
@property (nonatomic, strong) ARWorldTrackingConfiguration *configuration;

@end

void dispatch_once_on_main_thread(dispatch_once_t *predicate,
                                  dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        dispatch_once(predicate, block);
    } else {
        if (DISPATCH_EXPECT(*predicate == 0L, NO)) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                dispatch_once(predicate, block);
            });
        }
    }
}

@implementation RNWebGLARKit

+ (instancetype)sharedInstance {
    static RNWebGLARKit *instance = nil;
    static dispatch_once_t onceToken;

    dispatch_once_on_main_thread(&onceToken, ^{
        if (instance == nil) {
            ARSCNView *arView = [[ARSCNView alloc] init];
            instance = [[self alloc] initWithARView:arView];
        }
    });
    return instance;
}


- (instancetype)initWithARView:(ARSCNView *)arView {
    if ((self = [super init])) {
        self.arView = arView;

        // delegates
        arView.delegate = self;
        arView.session.delegate = self;

        // configuration(s)
        arView.autoenablesDefaultLighting = YES;
        arView.scene.rootNode.name = @"root";

        // start ARKit
        [self addSubview:arView];
        [self resume];
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.arView.frame = self.bounds;
}

- (void)pause {
    [self.session pause];
}

- (void)resume {
    [self.session runWithConfiguration:self.configuration];
}

- (void)reset {
    if (ARWorldTrackingConfiguration.isSupported) {
        [self.session runWithConfiguration:self.configuration options:ARSessionRunOptionRemoveExistingAnchors | ARSessionRunOptionResetTracking];
    }
}

#pragma mark - setter-getter

- (ARSession*)session {
    return self.arView.session;
}

- (BOOL)debug {
    return self.arView.showsStatistics;
}

- (void)setDebug:(BOOL)debug {
    if (debug) {
        self.arView.showsStatistics = YES;
        self.arView.debugOptions = ARSCNDebugOptionShowWorldOrigin | ARSCNDebugOptionShowFeaturePoints;
    } else {
        self.arView.showsStatistics = NO;
        self.arView.debugOptions = SCNDebugOptionNone;
    }
}

- (BOOL)planeDetection {
    ARWorldTrackingConfiguration *configuration = (ARWorldTrackingConfiguration *) self.session.configuration;
    return configuration.planeDetection == ARPlaneDetectionHorizontal;
}

- (void)setPlaneDetection:(BOOL)planeDetection {
    ARWorldTrackingConfiguration *configuration = (ARWorldTrackingConfiguration *) self.session.configuration;
    if (planeDetection) {
        configuration.planeDetection = ARPlaneDetectionHorizontal;
    } else {
        configuration.planeDetection = ARPlaneDetectionNone;
    }
    [self resume];
}

- (BOOL)lightEstimation {
    ARConfiguration *configuration = self.session.configuration;
    return configuration.lightEstimationEnabled;
}

- (void)setLightEstimation:(BOOL)lightEstimation {
    ARConfiguration *configuration = self.session.configuration;
    configuration.lightEstimationEnabled = lightEstimation;
    [self resume];
}

- (ARWorldAlignment)worldAlignment {
    ARConfiguration *configuration = self.session.configuration;
    return configuration.worldAlignment;
}

- (void)setWorldAlignment:(ARWorldAlignment)worldAlignment {
    ARConfiguration *configuration = self.configuration;
    if (worldAlignment == ARWorldAlignmentGravityAndHeading) {
        configuration.worldAlignment = ARWorldAlignmentGravityAndHeading;
    } else if (worldAlignment == ARWorldAlignmentCamera) {
        configuration.worldAlignment = ARWorldAlignmentCamera;
    } else {
        configuration.worldAlignment = ARWorldAlignmentGravity;
    }
    [self resume];
}

#pragma mark - Lazy loads

-(ARWorldTrackingConfiguration *)configuration {
    if (_configuration) {
        return _configuration;
    }

    if (!ARWorldTrackingConfiguration.isSupported) {}

    _configuration = [ARWorldTrackingConfiguration new];
    _configuration.planeDetection = ARPlaneDetectionHorizontal;

    return _configuration;
}


#pragma mark - ARSCNViewDelegate

- (void)renderer:(id <SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    if (![anchor isKindOfClass:[ARPlaneAnchor class]]) {
        return;
    }
    ARPlaneAnchor *planeAnchor = (ARPlaneAnchor *)anchor;
    NSLog(@"Did plane detect");
    if (self.onPlaneDetected) {
        self.onPlaneDetected(@{
                               @"id": planeAnchor.identifier.UUIDString,
                               @"alignment": @(planeAnchor.alignment),
                               @"node": @{ @"x": @(node.position.x), @"y": @(node.position.y), @"z": @(node.position.z) },
                               @"center": @{ @"x": @(planeAnchor.center.x), @"y": @(planeAnchor.center.y), @"z": @(planeAnchor.center.z) },
                               @"extent": @{ @"x": @(planeAnchor.extent.x), @"y": @(planeAnchor.extent.y), @"z": @(planeAnchor.extent.z) },
                               });
    }
}

- (void)renderer:(id <SCNSceneRenderer>)renderer willUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
}

- (void)renderer:(id <SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    ARPlaneAnchor *planeAnchor = (ARPlaneAnchor *)anchor;
    NSLog(@"Did plane update");
    if (self.onPlaneUpdated) {
        self.onPlaneUpdated(@{
                              @"id": planeAnchor.identifier.UUIDString,
                              @"alignment": @(planeAnchor.alignment),
                              @"node": @{ @"x": @(node.position.x), @"y": @(node.position.y), @"z": @(node.position.z) },
                              @"center": @{ @"x": @(planeAnchor.center.x), @"y": @(planeAnchor.center.y), @"z": @(planeAnchor.center.z) },
                              @"extent": @{ @"x": @(planeAnchor.extent.x), @"y": @(planeAnchor.extent.y), @"z": @(planeAnchor.extent.z) },
                              });
    }
}

- (void)renderer:(id <SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    ARPlaneAnchor *planeAnchor = (ARPlaneAnchor *)anchor;
    if (self.onPlaneRemoved) {
        self.onPlaneRemoved(@{
                              @"id": planeAnchor.identifier.UUIDString,
                              });
    }
}


static NSArray * nsArrayForMatrix(matrix_float4x4 mat) {
    const float *v = (const float *)&mat;
    return @[
             @(v[0]), @(v[1]), @(v[2]), @(v[3]),
             @(v[4]), @(v[5]), @(v[6]), @(v[7]),
             @(v[8]), @(v[9]), @(v[10]), @(v[11]),
             @(v[12]), @(v[13]), @(v[14]), @(v[15])
             ];
}

#pragma mark - ARSessionDelegate

- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame {
    NSLog(@"Did didUpdateFrame");
    if (self.onFrameUpdate) {
        matrix_float4x4 viewMat = [frame.camera viewMatrixForOrientation:UIInterfaceOrientationPortrait];
        matrix_float4x4 projMat = [frame.camera projectionMatrixForOrientation:UIInterfaceOrientationPortrait viewportSize:self.arView.frame.size zNear:0.1 zFar:1000];
        matrix_float4x4 transform = [frame.camera transform];
        self.onFrameUpdate(@{
                             @"camera": @{
                                     @"transform": nsArrayForMatrix(transform),
                                     @"viewMatrix": nsArrayForMatrix(viewMat),
                                     @"projectionMatrix": nsArrayForMatrix(projMat)
                                     },
                             @"lightEstimate": @{
                                     @"ambientIntensity": @(frame.lightEstimate.ambientIntensity),
                                     @"ambientColorTemperature": @(frame.lightEstimate.ambientColorTemperature),
                                     }
                               });
    }
}

@end

