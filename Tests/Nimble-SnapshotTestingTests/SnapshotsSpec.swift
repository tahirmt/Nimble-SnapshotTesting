//
//  SnapshotsSpecs.swift
//  Nimble-SnapshotTesting
//
//  Created by Mahmood Tahir on 2024-09-14.
//

#if os(iOS)
import Foundation
import Nimble_SnapshotTesting
import Quick
import UIKit
import Nimble
import SwiftUI
import XCTest

@available(iOS 14.0, *)
final class SnapshotsSpecs: QuickSpec {
    override class func spec() {
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

                it("should work with toEventually") {
                    let other = UILabel()
                    other.text = "Hello testing"

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        other.text = "Hello testing again"
                    }

                    expect(other).toEventually(haveValidSnapshot(as: .image))
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

                it("should record window") {
                    let window = UIWindow()
                    window.backgroundColor = .white
                    window.isHidden = false
                    window.frame = CGRect(origin: .zero, size: .init(width: 300, height: 500))
                    let viewController = UIViewController()
                    window.rootViewController = viewController
                    let view = UIButton(type: .contactAdd)
                    view.sizeToFit()
                    viewController.view.addSubview(view)

                    expect(window).to(haveValidSnapshot(as: .image))

                    viewController.view.backgroundColor = .blue
                    expect(window).to(haveValidSnapshot(as: .image))
                }

                it("should record window without root") {
                    let window = UIWindow()
                    window.backgroundColor = .white
                    window.isHidden = false
                    window.frame = CGRect(origin: .zero, size: .init(width: 300, height: 500))

                    let view = UIButton(type: .contactAdd)
                    view.sizeToFit()
                    window.addSubview(view)

                    expect(window).to(haveValidSnapshot(as: .image))

                    window.backgroundColor = .blue
                    expect(window).to(haveValidSnapshot(as: .image))
                }
            }
        }
    }
}

@available(iOS 14.0, *)
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
#endif
