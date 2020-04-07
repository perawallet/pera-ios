//
//  CBManagerState+Error.swift
//  algorand
//
//  Created by Omer Emre Aslan on 26.03.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import CoreBluetooth

extension CBManagerState {
    var errorDescription: (title: String?, subtitle: String?) {
        switch self {
        case .poweredOff:
            return ("ble-error-bluetooth-title".localized, "ble-error-fail-ble-connection-power".localized)
        case .unsupported:
            return ("ble-error-unsupported-device-title".localized, "ble-error-fail-ble-connection-unsupported".localized)
        case .unknown:
            return ("ble-error-unsupported-device-title".localized, "ble-error-fail-ble-connection-unsupported".localized)
        case .unauthorized:
            return ("ble-error-search-title".localized, "ble-error-fail-ble-connection-unauthorized".localized)
        case .resetting:
            return ("ble-error-bluetooth-title".localized, "ble-error-fail-ble-connection-resetting".localized)
        default:
            return (nil, nil)
        }
    }
}
