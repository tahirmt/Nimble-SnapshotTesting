//
//  SnapshotSpec.swift
//  Example-SPMTests
//
//  Created by Mahmood Tahir on 2022-03-23.
//

import Foundation
import Quick
import Nimble
import Nimble_SnapshotTesting
import UIKit
import SwiftUI

final class SnapshotSpec: QuickSpec {
    override func spec() {
        describe("a SnapshotSpec") {
            context("recording snapshots") {
                it("shoud record") {
                    let testLabel = UILabel()
                    testLabel.text = "Hello World"

                    expect(testLabel).to(haveValidSnapshot(as: .image))
                }

                it("should support == syntax") {
                    let other = UILabel()
                    other.text = "Hello testing"

                    expect(other) == snapshot(on: .image)
                }

                it("should record snapshot of a codable") {
                    let object = TestCodable(stringValue: "What is the meaning of life", number: 42)

                    expect(object) == snapshot(on: .json)
                }

                it("should record snapshot of a SwiftUI view") {
                    let view = TestView()
                        .frame(width: 200, height: 50, alignment: .center)

                    expect(view).to(haveValidSnapshot(as: .image))
                }
            }
        }
    }
}

private struct TestView: View {
    var body: some View {
        HStack {
            Circle()
                .frame(width: 20, height: 20, alignment: .leading)

            Label("Hello World!", systemImage: "book.fill")
        }
    }
}

private struct TestCodable: Codable {
    let stringValue: String
    let number: Int
}
