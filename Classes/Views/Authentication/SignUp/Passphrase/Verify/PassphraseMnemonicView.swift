//
//  PassPhraseMnemonicView.swift

import UIKit

class PassphraseMnemonicView: BaseView {

    var isSelected = false {
        didSet {
            recustomizeAppearanceWhenSelectedStateDidChange()
        }
    }

    private lazy var backgroundImageView = UIImageView(image: img("bg-passphrase-verify"))
    
    private lazy var phraseLabel: UILabel = {
        let label = UILabel(frame: .zero)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTextColor(Colors.Text.primary)
            .withAlignment(.center)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    override func configureAppearance() {
        backgroundColor = .clear
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
            make.edges.equalToSuperview()
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}

extension PassphraseMnemonicView {
    func bind(_ viewModel: PassphraseMnemonicViewModel) {
        phraseLabel.text = viewModel.phrase
    }

    private func recustomizeAppearanceWhenSelectedStateDidChange() {
        backgroundImageView.image = isSelected ? img("bg-passphrase-verify-selected") : img("bg-passphrase-verify")
    }
}
