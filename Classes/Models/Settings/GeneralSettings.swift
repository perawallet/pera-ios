//
//  GeneralSettings.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.09.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

enum GeneralSettings: Settings {
    case developer
    case password
    case localAuthentication
    case notifications
    case rewards
    case language
    case currency
    case feedback
    case termsAndServices
    
    var image: UIImage? {
        switch self {
        case .developer:
            return img("icon-settings-developer")
        case .password:
            return img("icon-settings-password")
        case .localAuthentication:
            return img("icon-settings-faceid")
        case .notifications:
            return img("icon-settings-notification")
        case .rewards:
            return img("icon-settings-reward")
        case .language:
            return img("icon-settings-language")
        case .currency:
            return img("icon-settings-currency")
        case .feedback:
            return img("icon-feedback")
        case .termsAndServices:
            return img("icon-terms-and-services")
        }
    }
    
    var name: String {
        switch self {
        case .developer:
            return "settings-developer".localized
        case .password:
            return "settings-change-password".localized
        case .localAuthentication:
            return "settings-local-authentication".localized
        case .notifications:
            return "notifications-title".localized
        case .rewards:
            return "rewards-show-title".localized
        case .language:
            return "settings-language".localized
        case .currency:
            return "settings-currency".localized
        case .feedback:
            return "feedback-title".localized
        case .termsAndServices:
            return "terms-and-services-title".localized
        }
    }
}
