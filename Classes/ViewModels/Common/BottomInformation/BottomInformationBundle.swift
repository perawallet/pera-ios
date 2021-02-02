//
//  BottomInformationBundle.swift

import UIKit

struct BottomInformationBundle {
    let title: String
    let image: UIImage?
    let explanation: String
    let actionTitle: String?
    let actionImage: UIImage?
    let closeBackgroundImage: UIImage?
    let closeTitle: String
    let actionHandler: EmptyHandler?
    
    init(
        title: String,
        image: UIImage?,
        explanation: String,
        actionTitle: String? = nil,
        actionImage: UIImage? = nil,
        closeBackgroundImage: UIImage? = img("bg-light-gray-button"),
        closeTitle: String = "title-cancel".localized,
        actionHandler: EmptyHandler? = nil
    ) {
        self.title = title
        self.image = image
        self.explanation = explanation
        self.actionTitle = actionTitle
        self.actionImage = actionImage
        self.closeBackgroundImage = closeBackgroundImage
        self.closeTitle = closeTitle
        self.actionHandler = actionHandler
    }
}
