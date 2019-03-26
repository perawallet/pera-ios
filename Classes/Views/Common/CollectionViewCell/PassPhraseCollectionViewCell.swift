//
//  PassPhraseCollectionViewCell.swift
//  algorand
//
//  Created by Omer Emre Aslan on 25.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

enum PassPhraseMode {
    case correct
    case wrong
    case idle
}

class PassPhraseCollectionViewCell: BaseCollectionViewCell<UIView> {
    fileprivate enum Color {
        static let wrongBackground = rgb(0.93, 0.14, 0.14)
        static let correctBackground = SharedColors.green
    }
    
    private(set) var mode: PassPhraseMode = .idle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        mode = .idle
        
        updateLayout(animated: false)
    }
    
    private(set) lazy var phraseLabel: UILabel = {
        UILabel(frame: .zero)
            .withFont(PassPhraseCollectionViewCell.font)
            .withTextColor(UIColor.black)
            .withAlignment(.center)
    }()
    
    override func configureAppearance() {
        super.configureAppearance()
        
        contextView.backgroundColor = UIColor.white
        contextView.layer.cornerRadius = 10.0
        
        contextView.addSubview(phraseLabel)
        phraseLabel.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
    }
    
    static var font: UIFont {
        return UIFont.font(Font.opensans, withWeight: .semiBold(size: 13.0))
    }
    
    func setMode(_ mode: PassPhraseMode) {
        self.mode = mode
        self.updateLayout(animated: true)
    }
}

// MARK: - Helpers
extension PassPhraseCollectionViewCell {
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
            contextView.backgroundColor = UIColor.white
            phraseLabel.textColor = UIColor.black
        case .correct:
            contextView.backgroundColor = Color.correctBackground
        case .wrong:
            contextView.backgroundColor = Color.wrongBackground
        }
    }
}
