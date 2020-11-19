//
//  PassPhraseMnemonicView.swift
//  algorand
//
//  Created by Omer Emre Aslan on 27.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PassphraseMnemonicView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) var mode: PassphraseMode = .idle
    
    private lazy var backgroundImageView = UIImageView(image: img("bg-passphrase-verify", isTemplate: true))
    
    private(set) lazy var phraseLabel: UILabel = {
        UILabel(frame: .zero)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTextColor(Colors.Text.primary)
            .withAlignment(.center)
    }()
    
    override func configureAppearance() {
        backgroundImageView.tintColor = Colors.Background.secondary
        layer.cornerRadius = 24.0
    }
    
    override func prepareLayout() {
        setupBackgroundImageViewLayout()
        setupPhraseLabelLayout()
    }
}

extension PassphraseMnemonicView {
    private func setupBackgroundImageViewLayout() {
        addSubview(backgroundImageView)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupPhraseLabelLayout() {
        backgroundImageView.addSubview(phraseLabel)
        
        phraseLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(layout.current.centerOffset)
        }
    }
}

extension PassphraseMnemonicView {
    func setMode(_ mode: PassphraseMode, animated: Bool = true) {
        self.mode = mode
        updateLayout(animated: animated)
    }
}

extension PassphraseMnemonicView {
    private func updateLayout(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.updateModeLayout()
            }
            return
        }
        
        updateModeLayout()
    }
    
    private func updateModeLayout() {
        switch mode {
        case .idle:
            phraseLabel.textColor = Colors.Text.primary
            backgroundImageView.tintColor = Colors.Background.secondary
        case .correct:
            phraseLabel.textColor = Colors.PassphraseMnemonic.selectedText
            backgroundImageView.tintColor = Colors.General.success
        case .wrong:
            phraseLabel.textColor = Colors.PassphraseMnemonic.selectedText
            backgroundImageView.tintColor = Colors.General.error
        }
    }
}

extension Colors {
    fileprivate enum PassphraseMnemonic {
        static let selectedText = color("selectedPassphraseMnemonicText")
    }
}

extension PassphraseMnemonicView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let centerOffset: CGFloat = -2.0
    }
}

enum PassphraseMode {
    case correct
    case wrong
    case idle
}
