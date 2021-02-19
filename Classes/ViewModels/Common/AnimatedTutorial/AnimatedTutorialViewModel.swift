//
//  AnimatedTutorialViewModel.swift

import Foundation

class AnimatedTutorialViewModel {
    private(set) var animation: String?
    private(set) var title: String?
    private(set) var description: NSAttributedString?
    private(set) var mainTitle: String?
    private(set) var actionTitle: String?

    init(tutorial: AnimatedTutorial) {
        setAnimation(from: tutorial)
        setTitle(from: tutorial)
        setDescription(from: tutorial)
        setMainTitle(from: tutorial)
        setActionTitle(from: tutorial)
    }

    private func setAnimation(from tutorial: AnimatedTutorial) {
        switch tutorial {
        case .backUp:
            animation = "shield_animation"
        case .recover:
            animation = "pen_animation"
        case .watchAccount:
            animation = ""
        case .writePassphrase:
            animation = "pen_animation"
        case .passcode:
            animation = "lock_animation"
        case .localAuthentication:
            animation = ""
        }
    }

    private func setTitle(from tutorial: AnimatedTutorial) {
        switch tutorial {
        case .backUp:
            title = "tutorial-title-back-up".localized
        case .recover:
            title = "tutorial-title-recover".localized
        case .watchAccount:
            title = ""
        case .writePassphrase:
            title = "tutorial-title-write".localized
        case .passcode:
            title = "tutorial-title-passcode".localized
        case .localAuthentication:
            title = "local-authentication-preference-title".localized
        }
    }

    private func setDescription(from tutorial: AnimatedTutorial) {
        switch tutorial {
        case .backUp:
            description = "tutorial-description-back-up".localized.attributed([.lineSpacing(1.2)])
        case .recover:
            description = "tutorial-description-recover".localized.attributed([.lineSpacing(1.2)])
        case .watchAccount:
            description = "".attributed([.lineSpacing(1.2)])
        case .writePassphrase:
            description = "tutorial-description-write".localized.attributed([.lineSpacing(1.2)])
        case .passcode:
            description = "tutorial-description-passcode".localized.attributed([.lineSpacing(1.2)])
        case .localAuthentication:
            description = "tutorial-description-local".localized.attributed([.lineSpacing(1.2)])
        }
    }

    private func setMainTitle(from tutorial: AnimatedTutorial) {
        switch tutorial {
        case .backUp:
            mainTitle = "tutorial-main-title-back-up".localized
        case .recover:
            mainTitle = "tutorial-main-title-recover".localized
        case .watchAccount:
            mainTitle = ""
        case .writePassphrase:
            mainTitle = "tutorial-main-title-write".localized
        case .passcode:
            mainTitle = "tutorial-main-title-passcode".localized
        case .localAuthentication:
            mainTitle = "local-authentication-preference-title".localized
        }
    }

    private func setActionTitle(from tutorial: AnimatedTutorial) {
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
