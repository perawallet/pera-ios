//
//  LedgerTroubleshootInstallAppView.swift
//  algorand
//
//  Created by Omer Emre Aslan on 26.03.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

protocol LedgerTroubleshootInstallAppViewDelegate: class {
    func ledgerTroubleshootInstallAppView(_ view: LedgerTroubleshootInstallAppView, didTapUrl url: URL)
}

class LedgerTroubleshootInstallAppView: BaseView {
    private lazy var numberOneView: LedgerTutorialNumberView = {
        let numberView = LedgerTutorialNumberView()
        numberView.setNumber(1)
        numberView.setCornerRadius(16)
        return numberView
    }()
    
    private lazy var numberOneTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = .link
        textView.textContainerInset = .zero
        return textView
    }()
    
    private lazy var numberTwoView: LedgerTutorialNumberView = {
        let numberView = LedgerTutorialNumberView()
        numberView.setNumber(2)
        numberView.setCornerRadius(16)
        return numberView
    }()
    
    private lazy var numberTwoTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = .link
        textView.textContainerInset = .zero
        return textView
    }()
    
    weak var delegate: LedgerTroubleshootInstallAppViewDelegate?
    
    override func configureAppearance() {
        backgroundColor = .white
        
        bindData()
    }
       
    override func prepareLayout() {
        setupFirstTutorialLayout()
        setupSecondTutorialLayout()
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        
        numberOneTextView.delegate = self
    }
}

// MARK: Data Binding
extension LedgerTroubleshootInstallAppView {
    private func bindData() {
        bindHtml("ledger-troubleshooting-install-app-first-html".localized, to: numberOneTextView)
        bindHtml("ledger-troubleshooting-install-app-second-html".localized, to: numberTwoTextView)
    }
    
    private func bindHtml(_ html: String?, to textView: UITextView) {
        guard let data = html?.data(using: .unicode),
            let attributedString = try? NSMutableAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil) else {
                return
        }
        
        attributedString.addAttributes([NSAttributedString.Key.font: UIFont.font(.avenir, withWeight: .medium(size: 14.0)),
                                        NSAttributedString.Key.foregroundColor: SharedColors.black],
                                       range: NSRange(location: 0, length: attributedString.string.count))
        textView.attributedText = attributedString
    }
}

// MARK: Layout
extension LedgerTroubleshootInstallAppView {
    private func setupFirstTutorialLayout() {
        addSubview(numberOneView)
        numberOneView.snp.makeConstraints { maker in
            maker.leading.top.equalToSuperview().inset(20)
            maker.height.width.equalTo(32)
        }
        
        addSubview(numberOneTextView)
        numberOneTextView.snp.makeConstraints { maker in
            maker.trailing.equalToSuperview().inset(20)
            maker.leading.equalTo(numberOneView.snp.trailing).offset(16)
            maker.top.equalTo(numberOneView)
            maker.height.equalTo(40)
        }
    }
    
    private func setupSecondTutorialLayout() {
        addSubview(numberTwoView)
        numberTwoView.snp.makeConstraints { maker in
            maker.leading.equalTo(numberOneView)
            maker.top.equalTo(numberOneTextView.snp.bottom).offset(40)
            maker.height.width.equalTo(32)
        }
        
        addSubview(numberTwoTextView)
        numberTwoTextView.snp.makeConstraints { maker in
            maker.trailing.equalToSuperview().inset(20)
            maker.leading.equalTo(numberTwoView.snp.trailing).offset(16)
            maker.top.equalTo(numberTwoView)
            maker.height.equalTo(80)
        }
    }
}

// MARK: UITextViewDelegate
extension LedgerTroubleshootInstallAppView: UITextViewDelegate {
    func textView(_ textView: UITextView,
                  shouldInteractWith URL: URL,
                  in characterRange: NSRange,
                  interaction: UITextItemInteraction) -> Bool {
        delegate?.ledgerTroubleshootInstallAppView(self, didTapUrl: URL)
        return false
    }
}
