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
//  PassPhraseMnemonicView.swift

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
