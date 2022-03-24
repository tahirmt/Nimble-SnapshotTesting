import Foundation
import Nimble
import SnapshotTesting

/// Set the global recording mode for `SnapshotTesting`
/// - Parameter record: The new value of recording mode
public func setSnapshotRecordingMode(_ record: Bool) {
    SnapshotTesting.isRecording = record
}

/// Configure failure messages for the given diff tool for `SnapshotTesting`. For example for Kleidoscope use `ksdiff`
/// - Parameter diffTool: diff tool command name
public func setSnapshotDiffTool(_ diffTool: String?) {
    SnapshotTesting.diffTool = diffTool
}

/// Validates the given `Value` using the `strategy` against a pre-recorded snapshot or records a new snapshot
/// - Parameters:
///   - strategy: Recording strategy for the given `Value`
///   - name: The name of the snapshot. If not provided, it will be automatically created
///   - recording: Whether or not to turn on recording mode for this test
///   - snapshotDirectory: Optional directory to save snapshots. By default snapshots will be saved in a directory with the same name as the test file, and that directory will sit inside a directory `__Snapshots__` that sits next to your test file.
///   - timeout: The amount of time a snapshot must be generated in.
///   - file: The file in which failure occurred. Defaults to the file name of the test case in which this function was called.
///   - testName: The name of the test in which failure occurred. Defaults to a sanitized name based on the quick context.
///   - line: The line number on which failure occurred. Defaults to the line number on which this function was called.
///   - function: The function name. This is used as a fallback if the currently running test is not found
/// - Returns: A predicate to use in Nimble
public func haveValidSnapshot<Value, Format>(
    as strategy: Snapshotting<Value, Format>,
    named name: String? = nil,
    record: Bool = false,
    snapshotDirectory: String? = nil,
    timeout: TimeInterval = 5,
    file: StaticString = #file,
    testName: String? = nil,
    line: UInt = #line,
    function: String = #function
) -> Predicate<Value> {
    haveValidSnapshot(as: [strategy],
                      named: name,
                      record: record,
                      snapshotDirectory: snapshotDirectory,
                      timeout: timeout,
                      file: file,
                      testName: testName,
                      line: line,
                      function: function
    )
}

/// Validates the given `Value` using the `strategies` against a pre-recorded snapshot or records a new snapshot
/// - Parameters:
///   - strategies: An array of recording strategies
///   - name: The name of the snapshot. If not provided, it will be automatically created
///   - recording: Whether or not to turn on recording mode for this test
///   - snapshotDirectory: Optional directory to save snapshots. By default snapshots will be saved in a directory with the same name as the test file, and that directory will sit inside a directory `__Snapshots__` that sits next to your test file.
///   - timeout: The amount of time a snapshot must be generated in.
///   - file: The file in which failure occurred. Defaults to the file name of the test case in which this function was called.
///   - testName: The name of the test in which failure occurred. Defaults to a sanitized name based on the quick context.
///   - line: The line number on which failure occurred. Defaults to the line number on which this function was called.
///   - function: The function name. This is used as a fallback if the currently running test is not found
/// - Returns: A predicate to use in Nimble
public func haveValidSnapshot<Value, Format>(
    as strategies: [Snapshotting<Value, Format>],
    named name: String? = nil,
    record: Bool = false,
    snapshotDirectory: String? = nil,
    timeout: TimeInterval = 5,
    file: StaticString = #file,
    testName: String? = nil,
    line: UInt = #line,
    function: String = #function
) -> Predicate<Value> {
    return Predicate { actualExpression in
        guard let value = try actualExpression.evaluate() else {
            return PredicateResult(status: .fail, message: .fail("have valid snapshot"))
        }

        let testName = testName ?? CurrentTestCaseTracker.shared.currentTestCase?.sanitizedName ?? function

        var failureMessages: [String] = []

        for strategy in strategies {
            if let errorMessage = verifySnapshot(matching: value,
                                                 as: strategy,
                                                 named: name,
                                                 record: record,
                                                 timeout: timeout,
                                                 file: file,
                                                 testName: testName,
                                                 line: line) {
                // failed
                failureMessages.append(errorMessage)
            }
        }

        return PredicateResult(
            bool: failureMessages.isEmpty,
            message: .fail(failureMessages.joined(separator: ",\n"))
        )
    }
}
