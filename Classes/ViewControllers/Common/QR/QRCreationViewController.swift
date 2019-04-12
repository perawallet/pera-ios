//
//  QRCreationViewController.swift
//  algorand
//
//  Created by Omer Emre Aslan on 28.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SnapKit

enum QRMode {
    case address
    case mnemonic
    case algosReceive
}

class QRCreationViewController: BaseScrollViewController {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let bottomInset: CGFloat = 20.0
    }
    
    private let layout = Layout<LayoutConstants>()
    private let qrText: String
    
    init(configuration: ViewControllerConfiguration,
         qrText: String) {
        self.qrText = qrText
        super.init(configuration: configuration)
    }
    
    var mode: QRMode = .mnemonic
    
    // MARK: Configuration
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var hidesCloseBarButtonItem: Bool {
        return true
    }
    
    // MARK: Components
    
    private(set) lazy var cancelButton: UIButton = {
        UIButton(type: .custom)
            .withFont(UIFont.font(.montserrat, withWeight: .bold(size: 14.0)))
            .withBackgroundImage(img("bg-dark-gray-button-big"))
            .withTitle("title-close".localized)
            .withTitleColor(SharedColors.black)
    }()
    
    private(set) lazy var shareButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("bg-blue-button"))
            .withImage(img("icon-share", isTemplate: true))
            .withTitle("title-share".localized)
            .withTitleColor(UIColor.white)
            .withTintColor(UIColor.white)
            .withFont(UIFont.font(.montserrat, withWeight: .semiBold(size: 12.0)))
            .withImageEdgeInsets(UIEdgeInsets(top: 0, left: -10.0, bottom: 0, right: 0))
            .withTitleEdgeInsets(UIEdgeInsets(top: 0, left: 5.0, bottom: 0, right: 0))
    }()
    
    private lazy var qrSelectableLabel: QRSelectableLabel = {
        let qrSelectableLabel = QRSelectableLabel()
        qrSelectableLabel.delegate = self
        return qrSelectableLabel
    }()
    
    private(set) lazy var qrView: QRView = {
        let qrText = QRText(mode: self.mode, text: self.qrText)
        return QRView(qrText: qrText)
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "qr-creation-title".localized
        
        if mode == .address {
            qrSelectableLabel.label.text = self.qrText
        }
    }
    
    override func setListeners() {
        super.setListeners()
        
        cancelButton.addTarget(self, action: #selector(tap(cancel:)), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(tap(share:)), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupQRView()
        setupShareButtonLayout()
        
        if mode == .address {
            setupQRSelectableLabel()
        }
        
        setupCancelButtonLayout()
    }
}

// MARK: - Layout
extension QRCreationViewController {
    fileprivate func setupQRView() {
        contentView.addSubview(qrView)
        
        qrView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(75)
            make.height.equalTo(qrView.snp.width)
            make.top.equalToSuperview().inset(69.0 * verticalScale)
        }
    }
    
    fileprivate func setupShareButtonLayout() {
        contentView.addSubview(shareButton)
        
        shareButton.snp.makeConstraints { make in
            make.top.equalTo(qrView.snp.bottom).offset(35 * verticalScale)
            make.height.equalTo(45)
            make.width.equalTo(135)
            make.centerX.equalTo(qrView)
        }
    }
    
    fileprivate func setupQRSelectableLabel() {
        contentView.addSubview(qrSelectableLabel)
        
        qrSelectableLabel.snp.makeConstraints { make in
            make.top.equalTo(shareButton.snp.bottom).offset(50 * verticalScale)
            make.height.equalTo(105)
            make.leading.trailing.equalToSuperview().inset(30)
        }
    }
    
    fileprivate func setupCancelButtonLayout() {
        let constraintItem: ConstraintItem
        
        if mode == .address {
            constraintItem = qrSelectableLabel.snp.bottom
        } else {
            constraintItem = shareButton.snp.bottom
        }
        
        contentView.addSubview(cancelButton)
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(constraintItem).offset(60 * verticalScale)
            make.height.equalTo(56)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(layout.current.bottomInset + view.safeAreaBottom)
        }
    }
}

// MARK: - Actions
extension QRCreationViewController {
    @objc
    fileprivate func tap(cancel: UIButton) {
        closeScreen(by: .dismiss)
    }
    
    @objc
    fileprivate func tap(share: UIButton) {
        guard let qrImage = qrView.imageView.image else {
            return
        }
        
        let sharedItem = [qrImage]
        let activityViewController = UIActivityViewController(activityItems: sharedItem, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList]
        
        navigationController?.present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: - QRSelectableLabelDelegate
extension QRCreationViewController: QRSelectableLabelDelegate {
    func qrSelectableLabel(_ qrSelectableLabel: QRSelectableLabel,
                           didTapText text: String) {
        UIPasteboard.general.string = text
    }
}
