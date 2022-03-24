// https://github.com/Quick/Quick

import Quick
import Nimble
import Nimble_SnapshotTesting

class SnapshotsSpec: QuickSpec {
    override func spec() {
        describe("recording snapshots") {
            it("should record") {
                let testView = UILabel()
                testView.text = "Hello world"

                expect(testView).to(haveValidSnapshot(as: .image))
            }
        }
    }
}
