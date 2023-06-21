import Foundation
import Nimble
import SnapshotTesting

/// Set the global recording mode for `SnapshotTesting`
/// - Parameter record: The new value of recording mode
@available(*, deprecated, renamed: "isRecordingSnapshots")
public func setSnapshotRecordingMode(_ record: Bool) {
    SnapshotTesting.isRecording = record
}

/// The global recording mode for all snapshot tests
public var isRecordingSnapshots: Bool {
    get { SnapshotTesting.isRecording }
    set { SnapshotTesting.isRecording = newValue }
}

/// Configure failure messages for the given diff tool for `SnapshotTesting`. For example for Kleidoscope use `ksdiff`
/// - Parameter diffTool: diff tool command name
public func setSnapshotDiffTool(_ diffTool: String?) {
    SnapshotTesting.diffTool = diffTool
}

/// A counter is used internally for keeping track of unique test cases. Otherwise, we would end up with the library recording
/// new snapshots at every poll interval.
/// The uniqing strategy is to assume there will be only one expectation on one line of the file and if the line is different it will
/// increment the counter.
///
/// The counter is kept similar to how `SnapshotTesting` does it internally so if someone replaces the `toEventually` test with `to`
/// it will use the same identifiers.
private enum Counter {
    struct Info {
        let line: UInt
        let count: UInt
    }
    @Atomic static var identifiersMap: [String: Info] = [:]
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
                                                 named: name ?? testCaseIdentifier(line: line),
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

// MARK: - toEventually helpers

public extension PollingDefaults {
    /// Default poll interval used for snapshot `toEventuallyIfTestingSnapshot` expectation.
    static var snapshotPollInterval: NimbleTimeInterval = .milliseconds(200)
}

public extension SyncExpectation {
    /// Uses `toEventually` to test the predicate only if the snapshot global recording mode is turned off. If the recording mode is on it will use a `to` expectation with the `recordingDelay`.
    /// - Parameters:
    ///   - predicate: The predicate to evaluate. Ideally, we should only use the `haveValidSnapshot` predicate here with a `recordingDelay`
    ///   - timeout: The timeout for the test
    ///   - pollInterval: The polling interval for the test. It uses `AsyncDefaults.snapshotPollInterval` as the default
    ///   - description: Additional description for the test
    @available(*, noasync, message: "the sync version of `toEventuallyIfTestingSnapshots` does not work in async contexts. Use the async version with the same name as a drop-in replacement")
    func toEventuallyIfTestingSnapshots(_ predicate: Predicate<Value>,
                                        timeout: NimbleTimeInterval = PollingDefaults.timeout,
                                        pollInterval: NimbleTimeInterval = PollingDefaults.snapshotPollInterval,
                                        description: String? = nil) {
        if isRecordingSnapshots {
            to(predicate, description: description)
        }
        else {
            toEventually(predicate, timeout: timeout, pollInterval: pollInterval, description: description)
        }
    }

    /// Uses `toEventually` to test the predicate only if the snapshot global recording mode is turned off. If the recording mode is on it will use a `to` expectation with the `recordingDelay`.
    /// - Parameters:
    ///   - predicate: The predicate to evaluate. Ideally, we should only use the `haveValidSnapshot` predicate here with a `recordingDelay`
    ///   - timeout: The timeout for the test
    ///   - pollInterval: The polling interval for the test. It uses `AsyncDefaults.snapshotPollInterval` as the default
    ///   - description: Additional description for the test
    func toEventuallyIfTestingSnapshots(_ predicate: Predicate<Value>,
                                        timeout: NimbleTimeInterval = PollingDefaults.timeout,
                                        pollInterval: NimbleTimeInterval = PollingDefaults.snapshotPollInterval,
                                        description: String? = nil) async {
        if isRecordingSnapshots {
            to(predicate, description: description)
        }
        else {
            await toEventually(predicate, timeout: timeout, pollInterval: pollInterval, description: description)
        }
    }
}

/// Validates the given `Value` using the `strategy` against a pre-recorded snapshot or records a new snapshot
/// - Parameters:
///   - strategy: Recording strategy for the given `Value`
///   - name: The name of the snapshot. If not provided, it will be automatically created
///   - record: Whether or not to turn on recording mode for this test
///   - recordDelay: The delay for recording when recording mode is on. This does not apply when snapshot does not exist and recording mode is off.///   - snapshotDirectory: Optional directory to save snapshots. By default snapshots will be saved in a directory with the same name as the test file, and that directory will sit inside a directory `__Snapshots__` that sits next to your test file.
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
    recordDelay: TimeInterval,
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
                      recordDelay: recordDelay,
                      snapshotDirectory: snapshotDirectory,
                      timeout: timeout,
                      file: file,
                      testName: testName,
                      line: line,
                      function: function)
}

/// Returns a unique count for the test case. This number is incremented for each test in a test case but not if the test originated from the same line.
/// - Parameter line: The line the test executed from
/// - Returns: a unique identifier for this particular test run
private func testCaseIdentifier(line: UInt) -> String {
    let count: UInt

    if let identifier = currentTestCaseName() {
        let iteration = Counter.identifiersMap[identifier, default: .init(line: line, count: 1)]

        if iteration.line != line {
            count = iteration.count + 1
        }
        else {
            count = iteration.count
        }

        Counter.$identifiersMap.mutate {
            $0[identifier] = .init(line: line, count: count)
        }
    }
    else {
        count = 1
    }

    return "\(count)"
}

/// Validates the given `Value` using the `strategy` against a pre-recorded snapshot or records a new snapshot
/// - Parameters:
///   - strategy: Recording strategy for the given `Value`
///   - name: The name of the snapshot. If not provided, it will be automatically created
///   - record: Whether or not to turn on recording mode for this test
///   - recordDelay: The delay for recording when recording mode is on. This does not apply when snapshot does not exist and recording mode is off.
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
    recordDelay: TimeInterval,
    snapshotDirectory: String? = nil,
    timeout: TimeInterval = 5,
    file: StaticString = #file,
    testName: String? = nil,
    line: UInt = #line,
    function: String = #function
) -> Predicate<Value> {
    if SnapshotTesting.isRecording || record {
        return haveValidSnapshot(as: strategies.map { .wait(for: recordDelay, on: $0) },
                                 named: name,
                                 record: record,
                                 snapshotDirectory: snapshotDirectory,
                                 timeout: timeout,
                                 file: file,
                                 testName: testName,
                                 line: line,
                                 function: function)
    }
    else {
        return haveValidSnapshot(as: strategies,
                                 named: name,
                                 record: record,
                                 snapshotDirectory: snapshotDirectory,
                                 timeout: timeout,
                                 file: file,
                                 testName: testName,
                                 line: line,
                                 function: function)
    }
}

