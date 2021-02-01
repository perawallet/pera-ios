//
//  RekeyInstructionItemView.swift

import UIKit

class RekeyInstructionItemView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var informationImageView = UIImageView(image: img("icon-rekey-info"))
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withLine(.contained)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withAlignment(.left)
            .withTextColor(Colors.Text.primary)
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
        layer.cornerRadius = 12.0
        if !isDarkModeDisplay {
            applySmallShadow()
        }
    }
    
    override func prepareLayout() {
        setupInformationImageViewLayout()
        setupTitleLabelLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isDarkModeDisplay {
            updateShadowLayoutWhenViewDidLayoutSubviews(cornerRadius: 12.0)
        }
    }
    
    @available(iOS 12.0, *)
    override func preferredUserInterfaceStyleDidChange(to userInterfaceStyle: UIUserInterfaceStyle) {
        if userInterfaceStyle == .dark {
            removeShadows()
        } else {
            applySmallShadow()
        }
    }
}

extension RekeyInstructionItemView {
    private func setupInformationImageViewLayout() {
        addSubview(informationImageView)
        
        informationImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
            make.size.equalTo(layout.current.infoImageSize)
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(informationImageView.snp.trailing).offset(layout.current.titleInset)
            make.top.bottom.equalToSuperview().inset(layout.current.titleInset)
            make.trailing.equalToSuperview().inset(layout.current.titleInset)
        }
    }
}

extension RekeyInstructionItemView {
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
}

extension RekeyInstructionItemView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let infoImageSize = CGSize(width: 24.0, height: 24.0)
        let horizontalInset: CGFloat = 20.0
        let titleInset: CGFloat = 16.0
    }
}
