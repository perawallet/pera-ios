//
//  CBManagerState+Error.swift

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
