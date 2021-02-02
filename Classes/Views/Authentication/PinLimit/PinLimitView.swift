//
//  PinLimitView.swift

import UIKit

class PinLimitView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: PinLimitViewDelegate?
    
    private lazy var lockImageView: UIImageView = {
        let imageView = UIImageView(image: img("icon-lock", isTemplate: true))
        imageView.tintColor = Colors.General.error
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .medium(size: 24.0)))
            .withTextColor(Colors.Text.primary)
            .withText("pin-limit-title".localized)
    }()
    
    private lazy var subtitleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .regular(size: 16.0)))
            .withTextColor(Colors.Text.tertiary)
            .withText("pin-limit-too-many".localized)
    }()
    
    private lazy var tryAgainLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .regular(size: 16.0)))
            .withTextColor(Colors.Text.tertiary)
            .withText("pin-limit-try-again".localized)
    }()
    
    private lazy var counterLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .medium(size: 24.0)))
            .withTextColor(Colors.Text.primary)
    }()
    
    private lazy var resetButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("bg-button-red"))
            .withTitle("pin-limit-reset-all".localized)
            .withTitleColor(Colors.ButtonText.primary)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.tertiary
    }
    
    override func setListeners() {
        resetButton.addTarget(self, action: #selector(notifyDelegateToResetAllData), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupLockImageViewLayout()
        setupTryAgainLabelLayout()
        setupSubtitleLabelLayout()
        setupTitleLabelLayout()
        setupCounterLabelLayout()
        setupResetButtonLayout()
    }
}

extension PinLimitView {
    @objc
    private func notifyDelegateToResetAllData() {
        delegate?.pinLimitViewDidResetAllData(self)
    }
}

extension PinLimitView {
    private func setupLockImageViewLayout() {
        addSubview(lockImageView)
        
        lockImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.imageViewTopInset)
            make.size.equalTo(layout.current.unlockImageSize)
        }
    }
    
    private func setupTryAgainLabelLayout() {
        addSubview(tryAgainLabel)
        
        tryAgainLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupSubtitleLabelLayout() {
        addSubview(subtitleLabel)
        
        subtitleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(tryAgainLabel.snp.top).offset(layout.current.subtitleLabelBottomInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(subtitleLabel.snp.top).offset(layout.current.titleLabelBottomInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupCounterLabelLayout() {
        addSubview(counterLabel)
        
        counterLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(tryAgainLabel.snp.bottom).offset(layout.current.counterLabelTopInset)
        }
    }
    
    private func setupResetButtonLayout() {
        addSubview(resetButton)
        
        resetButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(layout.current.buttonBottomInset + safeAreaBottom)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension PinLimitView {
    func setCounterText(_ counter: String) {
        counterLabel.text = counter
    }
}

extension PinLimitView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let titleLabelBottomInset: CGFloat = -10.0
        let subtitleLabelBottomInset: CGFloat = -24.0
        let imageViewTopInset: CGFloat = 90.0
        let counterLabelTopInset: CGFloat = 4.0
        let buttonBottomInset: CGFloat = 30.0
        let horizontalInset: CGFloat = 20.0
        let unlockImageSize = CGSize(width: 48.0, height: 48.0)
    }
}

protocol PinLimitViewDelegate: class {
    func pinLimitViewDidResetAllData(_ pinLimitView: PinLimitView)
}
