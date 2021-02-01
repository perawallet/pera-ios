//
//  OptionsViewModel.swift

import UIKit

class OptionsViewModel {

    private(set) var image: UIImage?
    private(set) var title: String?
    private(set) var titleColor: UIColor?

    init(option: OptionsViewController.Options, account: Account) {
        setImage(for: option, with: account)
        setTitle(for: option, with: account)
        setTitleColor(for: option)
    }

    private func setImage(for option: OptionsViewController.Options, with account: Account) {
        switch option {
        case .rekey:
            image = img("icon-options-rekey")
        case .rekeyInformation:
            image = img("icon-qr")
        case .removeAsset:
            image = img("icon-trash")
        case .passphrase:
            image = img("icon-lock")
        case .notificationSetting:
            image = account.receivesNotification ? img("icon-options-mute-notification") : img("icon-options-unmute-notification")
        case .edit:
            image = img("icon-edit-account")
        case .removeAccount:
            image = img("icon-remove-account")
        }
    }

    private func setTitle(for option: OptionsViewController.Options, with account: Account) {
        switch option {
        case .rekey:
            title = "options-rekey".localized
        case .rekeyInformation:
            title = "options-auth-account".localized
        case .removeAsset:
            title = "options-remove-assets".localized
        case .passphrase:
            title = "options-view-passphrase".localized
        case .notificationSetting:
            title = account.receivesNotification ? "options-mute-notification".localized : "options-unmute-notification".localized
        case .edit:
            title = "options-edit-account-name".localized
        case .removeAccount:
            title = "options-remove-account".localized
        }
    }

    private func setTitleColor(for option: OptionsViewController.Options) {
        switch option {
        case .removeAccount:
            titleColor = Colors.General.error
        default:
            titleColor = Colors.Text.primary
        }
    }
}
