import Foundation
import Nimble
import SnapshotTesting

// Nicer syntax support using == operator

public struct Snapshot<Value, Format> {
    let strategies: [Snapshotting<Value, Format>]
    let name: String?
    let record: Bool?
    let timeout: TimeInterval
    let file: StaticString
    let line: UInt
    let function: String

    @available(*, deprecated, renamed: "init(as:name:record:timeout:file:line:function:)", message: "Renamed to align initializer name with haveValidSnapshot method")
    public init(on strategies: [Snapshotting<Value, Format>],
                name: String? = nil,
                record: Bool? = nil,
                timeout: TimeInterval = 5,
                file: StaticString = #file,
                line: UInt = #line,
                function: String = #function) {
        self.strategies = strategies
        self.name = name
        self.record = record
        self.timeout = timeout
        self.file = file
        self.line = line
        self.function = function
    }

    public init(as strategies: [Snapshotting<Value, Format>],
                name: String? = nil,
                record: Bool? = nil,
                timeout: TimeInterval = 5,
                file: StaticString = #file,
                line: UInt = #line,
                function: String = #function) {
        self.strategies = strategies
        self.name = name
        self.record = record
        self.timeout = timeout
        self.file = file
        self.line = line
        self.function = function
    }
}

@available(*, deprecated, renamed: "snapshot(as:name:record:timeout:file:line:function:)", message: "Renamed to align initializer name with haveValidSnapshot method")
@MainActor public func snapshot<Value, Format>(on strategy: Snapshotting<Value, Format>,
                                    name: String? = nil,
                                    record: Bool? = nil,
                                    timeout: TimeInterval = 5,
                                    file: StaticString = #file,
                                    line: UInt = #line,
                                    function: String = #function) -> Snapshot<Value, Format> {
    snapshot(as: [strategy],
             name: name,
             record: isRecordingSnapshots ?? record,
             timeout: timeout,
             file: file,
             line: line,
             function: function
    )
}

@MainActor public func snapshot<Value, Format>(as strategy: Snapshotting<Value, Format>,
                                    name: String? = nil,
                                    record: Bool? = nil,
                                    timeout: TimeInterval = 5,
                                    file: StaticString = #file,
                                    line: UInt = #line,
                                    function: String = #function) -> Snapshot<Value, Format> {
    snapshot(as: [strategy],
             name: name,
             record: isRecordingSnapshots ?? record,
             timeout: timeout,
             file: file,
             line: line,
             function: function
    )
}

@available(*, deprecated, renamed: "snapshot(as:name:record:timeout:file:line:function:)", message: "Renamed to align initializer name with haveValidSnapshot method")
@MainActor public func snapshot<Value, Format>(on strategies: [Snapshotting<Value, Format>],
                                    name: String? = nil,
                                    record: Bool? = nil,
                                    timeout: TimeInterval = 5,
                                    file: StaticString = #file,
                                    line: UInt = #line,
                                    function: String = #function) -> Snapshot<Value, Format> {
    Snapshot(as: strategies,
             name: name,
             record: isRecordingSnapshots ?? record,
             timeout: timeout,
             file: file,
             line: line,
             function: function
    )
}

@MainActor
public func snapshot<Value, Format>(as strategies: [Snapshotting<Value, Format>],
                                    name: String? = nil,
                                    record: Bool? = nil,
                                    timeout: TimeInterval = 5,
                                    file: StaticString = #file,
                                    line: UInt = #line,
                                    function: String = #function) -> Snapshot<Value, Format> {
    Snapshot(as: strategies,
             name: name,
             record: isRecordingSnapshots ?? record,
             timeout: timeout,
             file: file,
             line: line,
             function: function
    )
}

@MainActor
public func == <Value, Format>(lhs: SyncExpectation<Value>, rhs: Snapshot<Value, Format>) {
    lhs.to(haveValidSnapshot(as: rhs.strategies,
                             named: rhs.name,
                             record: rhs.record,
                             timeout: rhs.timeout,
                             file: rhs.file,
                             line: rhs.line,
                             function: rhs.function
                            ))
}
