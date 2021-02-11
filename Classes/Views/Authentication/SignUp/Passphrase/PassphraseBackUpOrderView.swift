//
//  PassphraseBackUpOrderView.swift

import UIKit

class PassphraseBackUpOrderView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var numberLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 12.0)))
            .withTextColor(Colors.General.success)
            .withAlignment(.left)
    }()
    
    private lazy var phraseLabel: UILabel = {
        let label = UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 16.0)))
            .withTextColor(Colors.Text.primary)
            .withAlignment(.left)
        
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    override func configureAppearance() {
        backgroundColor = .clear
    }
    
    override func prepareLayout() {
        setupNumberLabelLayout()
        setupPhraseLabelLayout()
    }
}

extension PassphraseBackUpOrderView {
    private func setupNumberLabelLayout() {
        addSubview(numberLabel)
        
        numberLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupPhraseLabelLayout() {
        addSubview(phraseLabel)

        phraseLabel.setContentHuggingPriority(.required, for: .horizontal)
        phraseLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        phraseLabel.snp.makeConstraints { make in
            make.centerY.equalTo(numberLabel)
            make.leading.equalTo(numberLabel.snp.trailing).offset(layout.current.leadingInset)
            make.trailing.lessThanOrEqualToSuperview()
        }
    }
}

extension PassphraseBackUpOrderView {
    func bind(_ viewModel: PassphraseBackUpOrderViewModel) {
        numberLabel.text = viewModel.number
        phraseLabel.text = viewModel.phrase
    }
}

extension PassphraseBackUpOrderView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let leadingInset: CGFloat = 16.0 * horizontalScale
    }
}
