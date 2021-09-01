//
//  HIPDevice.swift
//  Pods
//
//  Created by Karasuluoglu on 2.11.2020.
//

import Foundation

open class HIPDevice {
    public let os: OS
    public let osVersion: String
    public let model: String

    public init() {
        let processInfo = ProcessInfo.processInfo

        os = .current

        let operatingSystem = processInfo.operatingSystemVersion
        osVersion = "\(operatingSystem.majorVersion).\(operatingSystem.minorVersion).\(operatingSystem.patchVersion)"

        #if targetEnvironment(simulator)
        model = processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "simulator"
        #else
        /// <ref> https://github.com/mattgallagher/CwlUtils/blob/master/Sources/CwlUtils/CwlSysctl.swift
        let keys: [Int32]

        #if os(macOS)
        keys = [CTL_HW, HW_MODEL]
        #else
        keys = [CTL_HW, HW_MACHINE]
        #endif

        let modelData = keys.withUnsafeBufferPointer { keysPointer -> [Int8]? in
            var requiredSize = 0
            let preFlightResult = Darwin.sysctl(UnsafeMutablePointer<Int32>(mutating: keysPointer.baseAddress), UInt32(keys.count), nil, &requiredSize, nil, 0)

            if preFlightResult != 0 {
                return nil
            }

            let data = Array<Int8>(repeating: 0, count: requiredSize)
            let result = try? data.withUnsafeBufferPointer() { dataBuffer throws -> Int32 in
                return Darwin.sysctl(UnsafeMutablePointer<Int32>(mutating: keysPointer.baseAddress), UInt32(keys.count), UnsafeMutableRawPointer(mutating: dataBuffer.baseAddress), &requiredSize, nil, 0)
            }

            if result != 0 {
                return nil
            }
            return data
        }
        model = modelData?.withUnsafeBufferPointer { dataPointer -> String? in
            dataPointer.baseAddress.flatMap { String(validatingUTF8: $0) }
        } ?? "Unknown"
        #endif
    }
}

extension HIPDevice {
    public enum OS: String, Printable {
        case iOS = "iOS"
        case macOS = "macOS"
        case watchOS = "watchOS"
        case tvOS = "tvOS"

        public static var current: Self {
            #if os(macOS)
            return .macOS
            #elseif os(watchOS)
            return .watchOS
            #elseif os(tvOS)
            return .tvOS
            #else
            return .iOS
            #endif
        }
    }
}

extension HIPDevice: Printable {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return "\(model) \(os.debugDescription) \(osVersion)"
    }
}
