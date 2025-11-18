import Foundation
#if canImport(XCTest)
import XCTest

/// https://github.com/Frameio/swift-snapshot-testing/blob/main/Sources/SnapshotTesting/Diffing.swift#L5
/// The ability to compare `Value`s and convert them to and from `Data`.
public struct Diffing<Value> {
    /// Converts a value _to_ data.
    public var toData: (Value) -> Data
    
    /// Produces a value _from_ data.
    public var fromData: (Data) -> Value
    
    /// Compares two values. If the values do not match, returns a failure message and artifacts
    /// describing the failure.
    public var diff: (Value, Value) -> (message: String, artifacts: Artifacts)?
    
    public typealias Artifacts = (image: Value, diff: Value)
    
    /// Creates a new `Diffing` on `Value`.
    ///
    /// - Parameters:
    ///   - toData: A function used to convert a value _to_ data.
    ///   - fromData: A function used to produce a value _from_ data.
    ///   - diff: A function used to compare two values. If the values do not match, returns a failure
    public init(
        toData: @escaping (_ value: Value) -> Data,
        fromData: @escaping (_ data: Data) -> Value,
        diff: @escaping (_ lhs: Value, _ rhs: Value) -> (message: String, artifacts: Artifacts)?
    ) {
        self.toData = toData
        self.fromData = fromData
        self.diff = diff
    }
}
#endif
