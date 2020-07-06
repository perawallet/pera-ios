//
//  TooltipPresentable.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 6.07.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

protocol TooltipPresentable: UIPopoverPresentationControllerDelegate {
    func presentTooltip(with text: String, at sourceView: UIView)
    var configuration: ViewControllerConfiguration { get }
}

extension TooltipPresentable where Self: UIViewController {
    func presentTooltip(with text: String, at sourceView: UIView) {
        let tooltipViewController = TooltipViewController(title: text, configuration: configuration)
        tooltipViewController.presentationController?.delegate = self
        tooltipViewController.setSourceView(sourceView)
        present(tooltipViewController, animated: true)
    }
}
