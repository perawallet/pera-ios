//
//  HIPHeaders.swift
//  Pods
//
//  Created by Karasuluoglu on 2.11.2020.
//

import Foundation

public struct AppNameHeader: Header {
    public let key = "App-Name"
    public let value: String?

    public init(_ application: HIPApplication) {
        self.value = application.name
    }
}

public struct AppPackageNameHeader: Header {
    public let key = "App-Package-Name"
    public let value: String?

    public init(_ application: HIPApplication) {
        self.value = application.packageName
    }
}

public struct AppVersionHeader: Header {
    public let key = "App-Version"
    public let value: String?

    public init(_ application: HIPApplication) {
        self.value = application.version
    }
}

public struct ClientTypeHeader: Header {
    public let key = "Client-Type"
    public let value: String?

    public init(_ device: HIPDevice) {
        self.value = device.os.rawValue
    }
}

public struct DeviceOSVersionHeader: Header {
    public let key = "Device-OS-Version"
    public let value: String?

    public init(_ device: HIPDevice) {
        self.value = device.osVersion
    }
}

public struct DeviceModelHeader: Header {
    public let key = "Device-Model"
    public let value: String?

    public init(_ device: HIPDevice) {
        self.value = device.model
    }
}
