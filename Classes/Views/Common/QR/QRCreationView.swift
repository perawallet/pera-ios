//
//  QRCreationView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 30.04.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class QRCreationView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: QRCreationViewDelegate?
    
    private lazy var qrView = QRView(qrText: QRText(mode: draft.mode, address: draft.address, mnemonic: draft.mnemonic))
    
    private lazy var shareButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("bg-main-button-small"))
            .withImage(img("icon-share-white"))
            .withTitle("title-share-qr".localized)
            .withTitleColor(SharedColors.primaryButtonTitle)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withImageEdgeInsets(UIEdgeInsets(top: 0, left: -10.0, bottom: 0, right: 0))
            .withTitleEdgeInsets(UIEdgeInsets(top: 0, left: 5.0, bottom: 0, right: 0))
    }()
    
    private lazy var qrSelectableLabel = QRSelectableLabel()
    
    private let draft: QRCreationDraft
    
    init(draft: QRCreationDraft) {
        self.draft = draft
        super.init(frame: .zero)
    }
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        qrSelectableLabel.delegate = self
    }
    
    override func setListeners() {
        super.setListeners()
        shareButton.addTarget(self, action: #selector(notifyDelegateToShareQR), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupQRViewLayout()
        setupShareButtonLayout()
        setupQRSelectableLabelLayout()
    }
}

extension QRCreationView {
    @objc
    private func notifyDelegateToShareQR() {
        delegate?.qrCreationViewDidShare(self)
    }
}

extension QRCreationView {
    private func setupQRViewLayout() {
        addSubview(qrView)
        
        qrView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(qrView.snp.width)
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }
    
    private func setupShareButtonLayout() {
        addSubview(shareButton)
        
        shareButton.snp.makeConstraints { make in
            make.top.equalTo(qrView.snp.bottom).offset(layout.current.buttonTopInset)
            make.centerX.equalToSuperview()
            make.width.equalTo(layout.current.shareButtonWidth)
            
            if draft.isSelectable {
                make.bottom.lessThanOrEqualToSuperview().inset(layout.current.verticalInset)
            }
        }
    }
    
    private func setupQRSelectableLabelLayout() {
        if !draft.isSelectable {
            return
        }
        
        addSubview(qrSelectableLabel)
        
        qrSelectableLabel.snp.makeConstraints { make in
            make.top.equalTo(shareButton.snp.bottom).offset(layout.current.labelTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.verticalInset)
        }
    }
}

extension QRCreationView: QRSelectableLabelDelegate {
    func qrSelectableLabel(_ qrSelectableLabel: QRSelectableLabel, didTapText text: String) {
        delegate?.qrCreationView(self, didSelect: text)
    }
}

extension QRCreationView {
    func setAddress(_ address: String) {
        qrSelectableLabel.setAddress(address)
    }
    
    func getQRImage() -> UIImage? {
        return qrView.imageView.image
    }
}

extension QRCreationView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 70.0
        let buttonTopInset: CGFloat = 40.0
        let horizontalInset: CGFloat = 20.0
        let verticalInset: CGFloat = 20.0
        let labelTopInset: CGFloat = 60.0
        let shareButtonWidth: CGFloat = 168.0
    }
}

protocol QRCreationViewDelegate: class {
    func qrCreationViewDidShare(_ qrCreationView: QRCreationView)
    func qrCreationView(_ qrCreationView: QRCreationView, didSelect text: String)
}
