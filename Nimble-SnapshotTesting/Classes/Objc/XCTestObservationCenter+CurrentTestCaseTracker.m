#import "XCTestObservationCenter+CurrentTestCaseTracker.h"
#if __has_include("Nimble_SnapshotTesting-Swift.h")
    #import "Nimble_SnapshotTesting-Swift.h"
#elif SWIFT_PACKAGE
@import Nimble_SnapshotTesting;
#else
    #import <Nimble_SnapshotTesting/Nimble_SnapshotTesting-Swift.h>
#endif

@implementation XCTestObservationCenter (CurrentTestCaseTracker)

+ (void)load {
    [[self sharedTestObservationCenter] addTestObserver:[CurrentTestCaseTracker shared]];
}

@end
