#import <UIKit/UIKit.h>
#import <ARKit/ARKit.h>
#import <SceneKit/SceneKit.h>

typedef void (^RCTBubblingEventBlock)(NSDictionary *body);

@interface RNWebGLARKit : UIView

+ (instancetype)sharedInstance;
- (instancetype)initWithARView:(ARSCNView *)arView;

#pragma mark - Properties
@property (nonatomic, strong) ARSCNView *arView;
@property (nonatomic, assign) BOOL debug;
@property (nonatomic, assign) BOOL planeDetection;
@property (nonatomic, assign) BOOL lightEstimation;
@property (nonatomic, assign) ARWorldAlignment worldAlignment;
@property (nonatomic, copy) RCTBubblingEventBlock onPlaneDetected;
@property (nonatomic, copy) RCTBubblingEventBlock onPlaneUpdated;
@property (nonatomic, copy) RCTBubblingEventBlock onPlaneRemoved;
@property (nonatomic, copy) RCTBubblingEventBlock onFrameUpdate;

#pragma mark - Public Method
- (void)pause;
- (void)resume;
- (void)reset;

#pragma mark - Delegates
- (void)renderer:(id <SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor;
- (void)renderer:(id <SCNSceneRenderer>)renderer willUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor;
- (void)renderer:(id <SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor;
- (void)renderer:(id <SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor;
- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame;
- (void)session:(ARSession *)session cameraDidChangeTrackingState:(ARCamera *)camera;

@end
