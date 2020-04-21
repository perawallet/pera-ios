//
//  PassPhraseMnemonicView.swift
//  algorand
//
//  Created by Omer Emre Aslan on 27.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PassphraseMnemonicView: BaseView {
    
    private(set) var mode: PassphraseMode = .idle
    
    private(set) lazy var phraseLabel: UILabel = {
        UILabel(frame: .zero)
            .withFont(UIFont.font(.publicSans, withWeight: .medium(size: 14.0)))
            .withTextColor(color("primaryText"))
            .withAlignment(.center)
    }()
    
    override func configureAppearance() {
        backgroundColor = UIColor(named: "secondaryBackground")
        layer.cornerRadius = 24.0
    }
    
    override func prepareLayout() {
        setupPhraseLabelLayout()
    }
}

extension PassphraseMnemonicView {
    private func setupPhraseLabelLayout() {
        addSubview(phraseLabel)
        
        phraseLabel.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
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
    fileprivate func updateLayout(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.updateModeLayout()
            }
            return
        }
        
        updateModeLayout()
    }
    
    fileprivate func updateModeLayout() {
        phraseLabel.textColor = UIColor(named: "white")
        
        switch mode {
        case .idle:
            backgroundColor = UIColor(named: "secondaryBackground")
            phraseLabel.textColor = UIColor(named: "primaryText")
        case .correct:
            backgroundColor = UIColor(named: "primary")
        case .wrong:
            backgroundColor = UIColor(named: "red")
        }
    }
}

enum PassphraseMode {
    case correct
    case wrong
    case idle
}
