//
//  PassphraseDisplayViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 28.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PassphraseDisplayViewController: BaseViewController {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
    }
    
    private enum Colors {
        static let backgroundColor = rgba(0.04, 0.05, 0.07, 0.6)
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private let passPhrase: String
    
    init(account: Account, configuration: ViewControllerConfiguration) {
        self.passPhrase = account.mnemonics().joined(separator: " ")
        super.init(configuration: configuration)
    }

    // MARK: Components
    
    private lazy var passphraseDisplayView: PassphraseDisplayView = {
        let view = PassphraseDisplayView()
        return view
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        view.backgroundColor = Colors.backgroundColor
        
        passphraseDisplayView.passphraseLabel.attributedText = passPhrase.attributed([.lineSpacing(1.5)])
    }
    
    override func setListeners() {
        passphraseDisplayView.delegate = self
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        view.addSubview(passphraseDisplayView)
        
        passphraseDisplayView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.center.equalToSuperview()
        }
    }

}

// MARK: PassphraseDisplayViewDelegate

extension PassphraseDisplayViewController: PassphraseDisplayViewDelegate {
    
    func passphraseDisplayViewDidTapShareButton(_ passphraseDisplayView: PassphraseDisplayView) {
        let sharedItem = [passPhrase]
        let activityViewController = UIActivityViewController(activityItems: sharedItem, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList]
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    func passphraseDisplayViewDidTapDoneButton(_ passphraseDisplayView: PassphraseDisplayView) {
        dismissScreen()
    }
}
