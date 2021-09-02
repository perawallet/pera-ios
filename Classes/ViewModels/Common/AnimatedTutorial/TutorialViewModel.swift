// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  TutorialViewModel.swift

import UIKit
import Macaroon

final class TutorialViewModel: PairedViewModel {
    private(set) var image: UIImage?
    private(set) var title: String?
    private(set) var description: String?
    private(set) var mainTitle: String?
    private(set) var actionTitle: String?
    private(set) var warningDescription: String?

    init(_ model: Tutorial) {
        bindImage(model)
        bindTitle(model)
        bindDescription(model)
        bindMainTitle(model)
        bindActionTitle(model)
        bindWarningTitle(model)
    }
}

extension TutorialViewModel {
    private func bindImage(_ tutorial: Tutorial) {
        switch tutorial {
        case .backUp:
            image = img("shield")
        case .recover:
            image = img("key")
        case .watchAccount:
            image = img("eye")
        case .writePassphrase:
            image = img("pen")
        case .passcode:
            image = img("locked")
        case .localAuthentication:
            image = img("faceid")
        case .biometricAuthenticationEnabled:
            image = img("check")
        }
    }

    private func bindTitle(_ tutorial: Tutorial) {
        switch tutorial {
        case .backUp:
            title = "tutorial-title-back-up".localized
        case .recover:
            title = "tutorial-title-recover".localized
        case .watchAccount:
            title = "title-watch-account".localized
        case .writePassphrase:
            title = "tutorial-title-write".localized
        case .passcode:
            title = "tutorial-title-passcode".localized
        case .localAuthentication:
            title = "local-authentication-preference-title".localized
        case .biometricAuthenticationEnabled:
            title = "local-authentication-enabled-title".localized
        }
    }

    private func bindDescription(_ tutorial: Tutorial) {
        switch tutorial {
        case .backUp:
            description = "tutorial-description-back-up".localized
        case .recover:
            description = "tutorial-description-recover".localized
        case .watchAccount:
            description = "tutorial-description-watch".localized
        case .writePassphrase:
            description = "tutorial-description-write".localized
        case .passcode:
            description = "tutorial-description-passcode".localized
        case .localAuthentication:
            description = "tutorial-description-local".localized
        case .biometricAuthenticationEnabled:
            description = "local-authentication-enabled-subtitle".localized
        }
    }

    private func bindMainTitle(_ tutorial: Tutorial) {
        switch tutorial {
        case .backUp:
            mainTitle = "tutorial-main-title-back-up".localized
        case .recover:
            mainTitle = "tutorial-main-title-recover".localized
        case .watchAccount:
            mainTitle = "watch-account-create".localized
        case .writePassphrase:
            mainTitle = "tutorial-main-title-write".localized
        case .passcode:
            mainTitle = "tutorial-main-title-passcode".localized
        case .localAuthentication:
            mainTitle = "local-authentication-enable".localized
        case .biometricAuthenticationEnabled:
            mainTitle = "title-go-to-accounts".localized
        }
    }

    private func bindWarningTitle(_ tutorial: Tutorial) {
        switch tutorial {
        case .watchAccount:
            warningDescription = "tutorial-description-watch-warning".localized
        case .writePassphrase:
            warningDescription = "tutorial-description-write-warning".localized
        default:
            break
        }
    }

    private func bindActionTitle(_ tutorial: Tutorial) {
        switch tutorial {
        case .passcode:
            actionTitle = "tutorial-action-title-passcode".localized
        case .localAuthentication:
            actionTitle = "local-authentication-no".localized
        default:
            break
        }
    }
}
