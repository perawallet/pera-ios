// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  QRCreationView.swift

import UIKit
import MacaroonUIKit

class QRCreationView: View {
    weak var delegate: QRCreationViewDelegate?
    
    private lazy var labelTapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(notifyToCopyText(_:))
    )
        
    private lazy var qrView =
        QRView(qrText: QRText(mode: draft.mode, address: draft.address, mnemonic: draft.mnemonic))
    private lazy var addressView = QRAddressLabel()
    private lazy var copyButton = Button()
    private lazy var shareButton = Button()
    private lazy var copyFeedbackLabel = UILabel()
    private lazy var copyFeedbackView = UIView()
        
    private let draft: QRCreationDraft
    
    init(draft: QRCreationDraft) {
        self.draft = draft
        super.init(frame: .zero)
    }

    func setListeners() {
        shareButton.addTarget(self, action: #selector(notifyDelegateToShareQR), for: .touchUpInside)
        copyButton.addTarget(self, action: #selector(notifyToCopyText), for: .touchUpInside)
        addressView.addGestureRecognizer(labelTapGestureRecognizer)
    }
    
    func customize(_ theme: QRCreationViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        
        addCopyFeedbackLabel(theme)
        addQRView(theme)
        addLabel(theme)
        addCopyButton(theme)
        addShareButton(theme)
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension QRCreationView {
    @objc
    private func notifyDelegateToShareQR() {
        delegate?.qrCreationViewDidShare(self)
    }
    
    @objc
    private func notifyToCopyText(_ gestureRecognizer: UITapGestureRecognizer) {
        copyFeedbackView.isHidden = false
        
        delegate?.qrCreationView(self, didSelect: addressView.getAddress())
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.copyFeedbackView.isHidden = true
        }
    }
}

extension QRCreationView {
    private func addCopyFeedbackLabel(_ theme: QRCreationViewTheme) {
        copyFeedbackView.customizeAppearance(theme.copyFeedbackView)
        copyFeedbackView.layer.cornerRadius = 4.0
        copyFeedbackView.isHidden = true
        
        addSubview(copyFeedbackView)
        copyFeedbackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(2)
            $0.centerX.equalToSuperview()
        }
        
        copyFeedbackLabel.customizeAppearance(theme.copyFeedbackLabel)
        
        copyFeedbackView.addSubview(copyFeedbackLabel)
        copyFeedbackLabel.snp.makeConstraints {
            $0.setPaddings(theme.copyFeedBackInsets)
        }
    }
    
    private func addQRView(_ theme: QRCreationViewTheme) {
        addSubview(qrView)
        qrView.snp.makeConstraints {
            $0.height.equalTo(qrView.snp.width)
            $0.top.equalToSuperview().inset(theme.topInset)
            $0.centerX.equalToSuperview()
        }
    }
    private func addLabel(_ theme: QRCreationViewTheme) {
        addressView.customize(theme.addressTheme)
        
        addSubview(addressView)
        addressView.snp.makeConstraints {
            $0.top.equalTo(qrView.snp.bottom).offset(theme.labelTopInset)
            $0.leading.trailing.equalToSuperview().inset(theme.labelHorizontalInset)
        }
    }
    private func addCopyButton(_ theme: QRCreationViewTheme) {
        copyButton.customize(theme.copyButtonTheme)
        copyButton.bindData(ButtonCommonViewModel(
            title: "qr-creation-copy-address".localized,
            iconSet: [.normal("icon-qr-copy")])
        )
        copyButton.titleEdgeInsets = UIEdgeInsets(theme.buttonTitleInsets)
        
        addSubview(copyButton)
        copyButton.snp.makeConstraints {
            $0.top.equalTo(addressView.snp.bottom).offset(theme.copyButtonTopInset)
            $0.leading.trailing.equalToSuperview().inset(theme.buttonHorizontalInset)
        }
    }
    private func addShareButton(_ theme: QRCreationViewTheme) {
        shareButton.customize(theme.shareButtonTheme)
        shareButton.bindData(ButtonCommonViewModel(
            title: "title-share-qr".localized,
            iconSet: [.normal("icon-qr-share")])
        )
        shareButton.titleEdgeInsets = UIEdgeInsets(theme.buttonTitleInsets)
        
        addSubview(shareButton)
        shareButton.snp.makeConstraints {
            $0.top.equalTo(copyButton.snp.bottom).offset(theme.shareButtonTopInset)
            $0.leading.trailing.equalToSuperview().inset(theme.buttonHorizontalInset)
            $0.bottom.equalToSuperview().inset(safeAreaBottom + theme.bottomInset)
        }
    }
}

extension QRCreationView {
    func setAddress(_ address: String) {
        addressView.setAddress(address)
    }
    
    func getQRImage() -> UIImage? {
        return qrView.imageView.image
    }
}

protocol QRCreationViewDelegate: AnyObject {
    func qrCreationViewDidShare(_ qrCreationView: QRCreationView)
    func qrCreationView(_ qrCreationView: QRCreationView, didSelect text: String)
}
