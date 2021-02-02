//
//  OptionsContextView.swift

import UIKit

class OptionsContextView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var iconImageView = UIImageView()
    
    private(set) lazy var optionLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTextColor(Colors.Text.primary)
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }
    
    override func prepareLayout() {
        setupIconImageViewLayout()
        setupOptionLabelLayout()
    }
}

extension OptionsContextView {
    private func setupIconImageViewLayout() {
        addSubview(iconImageView)
        
        iconImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupOptionLabelLayout() {
        addSubview(optionLabel)
        
        optionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.labelLefInset)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension OptionsContextView {
    func bind(_ viewModel: OptionsViewModel) {
        iconImageView.image = viewModel.image
        optionLabel.text = viewModel.title
        optionLabel.textColor = viewModel.titleColor
    }
}

extension OptionsContextView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let labelLefInset: CGFloat = 56.0
    }
}
