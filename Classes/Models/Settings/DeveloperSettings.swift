//
//  DeveloperSettings.swift

import UIKit

enum DeveloperSettings: Settings {
    case nodeSettings
    case dispenser
    
    var image: UIImage? {
        switch self {
        case .nodeSettings:
            return img("icon-settings-node")
        case .dispenser:
            return img("icon-settings-dispenser")
        }
    }
    
    var name: String {
        switch self {
        case .nodeSettings:
            return "settings-server-node-settings".localized
        case .dispenser:
            return "settings-developer-dispenser".localized
        }
    }
}
