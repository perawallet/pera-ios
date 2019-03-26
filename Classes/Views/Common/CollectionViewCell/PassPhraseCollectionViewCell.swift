//
//  PassPhraseCollectionViewCell.swift
//  algorand
//
//  Created by Omer Emre Aslan on 25.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

enum PassPhraseMode {
    case selected
    case correct
    case wrong
    case idle
}

class PassPhraseCollectionViewCell: BaseCollectionViewCell<UIView> {
    var mode: PassPhraseMode = .idle {
        didSet {
            updateLayout()
        }
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
        return UIFont.font(Font.opensans, withWeight: .regular(size: 13.0))
    }
}

// MARK: - API
extension PassPhraseCollectionViewCell {
    func updateLayout() {
        switch mode {
        case .idle:
            contextView.backgroundColor = UIColor.white
        case .correct:
            contextView.backgroundColor = UIColor.green
        case .wrong:
            contextView.backgroundColor = UIColor.red
        case .selected:
            contextView.backgroundColor = UIColor.lightGray
        }
    }
}
