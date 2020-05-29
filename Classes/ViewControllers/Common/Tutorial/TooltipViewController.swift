//
//  TooltipViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class TooltipViewController: BaseViewController {
    
    private let layout = Layout<LayoutConstants>()
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    private lazy var tooltipLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withText(tooltipText)
            .withTextColor(SharedColors.white)
            .withLine(.contained)
            .withFont(UIFont.font(withWeight: .semiBold(size: 14.0)))
    }()
    
    private let tooltipText: String
    
    init(title: String, configuration: ViewControllerConfiguration) {
        tooltipText = title
        super.init(configuration: configuration)
        modalPresentationStyle = .popover
        setPreferredContentSize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.dismissScreen()
        }
    }
    
    override func configureAppearance() {
        view.backgroundColor = SharedColors.gray800
        popoverPresentationController?.backgroundColor = SharedColors.gray800
        popoverPresentationController?.permittedArrowDirections = .up
    }
    
    override func prepareLayout() {
        setupTooltipLabelLayout()
    }
}

extension TooltipViewController {
    private func setPreferredContentSize() {
        let tooltipFont = UIFont.font(withWeight: .semiBold(size: 14.0))
        var tooltipLabelSize = tooltipText.size(usingFont: tooltipFont)
        let totalHorizontalInset = layout.current.horizontalInset * 2
        
        if tooltipLabelSize.width > UIScreen.main.bounds.width - totalHorizontalInset {
            let maxHeight = tooltipText.height(withConstrained: UIScreen.main.bounds.width - totalHorizontalInset, font: tooltipFont)
            tooltipLabelSize.height = maxHeight
            tooltipLabelSize.width = UIScreen.main.bounds.width - totalHorizontalInset
        }
        
        preferredContentSize = CGSize(
            width: tooltipLabelSize.width + totalHorizontalInset,
            height: tooltipLabelSize.height + layout.current.verticalInset * 2
        )
    }
}

extension TooltipViewController {
    func setSourceView(_ sourceView: UIView) {
        popoverPresentationController?.sourceView = sourceView
        popoverPresentationController?.sourceRect = sourceView.bounds
    }
}

extension TooltipViewController {
    private func setupTooltipLabelLayout() {
        view.addSubview(tooltipLabel)
        
        tooltipLabel.setContentHuggingPriority(.required, for: .horizontal)
        tooltipLabel.setContentHuggingPriority(.required, for: .vertical)
        tooltipLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        tooltipLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        tooltipLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.safeEqualToTop(of: self).inset(layout.current.verticalInset)
            make.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
}

extension TooltipViewController {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let verticalInset: CGFloat = 12.0
    }
}
