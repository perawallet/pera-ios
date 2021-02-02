//
//  BottomInformationViewModel.swift

import UIKit

class BottomInformationViewModel {
    private(set) var attributedTitle: NSAttributedString?
    private(set) var titleAlignment: NSTextAlignment = .center
    private(set) var attributedExplanation: NSAttributedString?
    private(set) var explanationAlignment: NSTextAlignment = .center
    private(set) var image: UIImage?
    private(set) var actionButtonTitle: String?
    private(set) var actionImage: UIImage?
    private(set) var closeButtonTitle: String?
    private(set) var closeImage: UIImage?

    init(configurator: BottomInformationBundle) {
        setAttributedTitle(from: configurator)
        setAttributedExplanation(from: configurator)
        setImage(from: configurator)
        setButtonDetails(from: configurator)
    }

    private func setAttributedTitle(from configurator: BottomInformationBundle) {
        attributedTitle = configurator.title.attributed([.lineSpacing(1.2)])
    }

    private func setAttributedExplanation(from configurator: BottomInformationBundle) {
        attributedExplanation = configurator.explanation.attributed([.lineSpacing(1.2)])
    }

    private func setImage(from configurator: BottomInformationBundle) {
        image = configurator.image
    }

    private func setButtonDetails(from configurator: BottomInformationBundle) {
        actionButtonTitle = configurator.actionTitle
        actionImage = configurator.actionImage
        closeButtonTitle = configurator.closeTitle
        closeImage = configurator.closeBackgroundImage
    }
}
