// https://github.com/Quick/Quick

import Quick
import Nimble
import Nimble_SnapshotTesting

class SnapshotsSpec: QuickSpec {
    override class func spec() {
        describe("recording snapshots") {
            it("should record") {
                let testView = UILabel()
                testView.text = "Hello world"

                expect(testView).to(haveValidSnapshot(as: .image))
            }

            it("should record a snapshot and work with toEventually") {
                let testView = UILabel()
                testView.text = "Hello world"

                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                    testView.text = "Other world"
                }

                expect(testView).toEventuallyIfTestingSnapshots(haveValidSnapshot(as: .image, recordDelay: 0.3))
            }
        }
    }
}
