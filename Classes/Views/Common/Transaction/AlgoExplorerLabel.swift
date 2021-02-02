//
//  AlgoExplorerLabel.swift

import UIKit

class AlgoExplorerLabel: UILabel {
    
    weak var delegate: AlgoExplorerLabelDelegate?
    
    override public var canBecomeFirstResponder: Bool {
        return true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupInteractions()
        setupMenuItems()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(copyText) || action == #selector(notifyDelegateToOpenAlgoExplorer)
    }
}

extension AlgoExplorerLabel {
    private func setupInteractions() {
        isUserInteractionEnabled = true
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(showMenuController)))
    }

    private func setupMenuItems() {
        let copyItem = UIMenuItem(title: "title-copy".localized, action: #selector(copyText))
        let explorerItem = UIMenuItem(title: "transaction-id-open-explorer".localized, action: #selector(notifyDelegateToOpenAlgoExplorer))
        UIMenuController.shared.menuItems = [copyItem, explorerItem]
    }
}

extension AlgoExplorerLabel {
    @objc
    private func showMenuController() {
        if let superView = superview {
            let menuController = UIMenuController.shared
            menuController.setTargetRect(frame, in: superView)
            menuController.setMenuVisible(true, animated: true)
            becomeFirstResponder()
        }
    }
    
    @objc
    private func copyText() {
        UIPasteboard.general.string = text
    }
    
    @objc
    private func notifyDelegateToOpenAlgoExplorer() {
        delegate?.algoExplorerLabelDidOpenExplorer(self)
    }
}

protocol AlgoExplorerLabelDelegate: class {
    func algoExplorerLabelDidOpenExplorer(_ algoExplorerLabel: AlgoExplorerLabel)
}
