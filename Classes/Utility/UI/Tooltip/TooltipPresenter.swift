//
//  TooltipPresentable.swift

import UIKit

protocol TooltipPresenter: UIPopoverPresentationControllerDelegate {
    func presentTooltip(with text: String, using configuration: ViewControllerConfiguration, at sourceView: UIView)
}

extension TooltipPresenter where Self: UIViewController {
    func presentTooltip(with text: String, using configuration: ViewControllerConfiguration, at sourceView: UIView) {
        let tooltipViewController = TooltipViewController(title: text, configuration: configuration)
        tooltipViewController.presentationController?.delegate = self
        tooltipViewController.setSourceView(sourceView)
        present(tooltipViewController, animated: true)
    }
}
