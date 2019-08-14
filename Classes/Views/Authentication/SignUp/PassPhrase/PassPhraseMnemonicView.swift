//
//  PassPhraseMnemonicView.swift
//  algorand
//
//  Created by Omer Emre Aslan on 27.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

enum PassPhraseMode {
    case correct
    case wrong
    case idle
}

class PassPhraseMnemonicView: UIView {
    fileprivate enum Color {
        static let wrongBackground = SharedColors.darkGray
        static let correctBackground = SharedColors.purple
    }
    
    enum Font {
        static let phraseLabel = UIFont.font(.overpass, withWeight: .semiBold(size: 13.0))
    }
    
    private(set) var mode: PassPhraseMode = .idle
    
    private(set) lazy var phraseLabel: UILabel = {
        UILabel(frame: .zero)
            .withFont(Font.phraseLabel)
            .withTextColor(UIColor.black)
            .withAlignment(.center)
    }()
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout
extension PassPhraseMnemonicView {
    fileprivate func setupLayout() {
        backgroundColor = UIColor.white
        layer.cornerRadius = 10.0
        
        addSubview(phraseLabel)
        phraseLabel.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
    }
}

// MARK: - API
extension PassPhraseMnemonicView {
    func setMode(_ mode: PassPhraseMode, animated: Bool = true) {
        self.mode = mode
        self.updateLayout(animated: animated)
    }
}

// MARK: - Helpers
extension PassPhraseMnemonicView {
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
        phraseLabel.textColor = UIColor.white
        
        switch mode {
        case .idle:
            backgroundColor = UIColor.white
            phraseLabel.textColor = UIColor.black
        case .correct:
            backgroundColor = Color.correctBackground
        case .wrong:
            backgroundColor = Color.wrongBackground
        }
    }
}
