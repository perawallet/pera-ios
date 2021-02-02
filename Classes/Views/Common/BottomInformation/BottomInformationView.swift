//
//  BottomInformationView.swift

import UIKit

class BottomInformationView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withLine(.contained)
            .withAlignment(.center)
            .withTextColor(Colors.Text.primary)
    }()
    
    private(set) lazy var imageView = UIImageView()
    
    private(set) lazy var explanationLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withLine(.contained)
            .withAlignment(.center)
            .withTextColor(Colors.Text.primary)
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupImageViewLayout()
        setupExplanationLabelLayout()
    }
}

extension BottomInformationView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupImageViewLayout() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.imageVerticalInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupExplanationLabelLayout() {
        addSubview(explanationLabel)
        
        explanationLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(layout.current.explanationLabelInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension BottomInformationView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 16.0
        let horizontalInset: CGFloat = 32.0
        let imageVerticalInset: CGFloat = 28.0
        let explanationLabelInset: CGFloat = 20.0
    }
}
