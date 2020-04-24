//
//  LedgerTroubleshootBluetoothConnectionView.swift
//  algorand
//
//  Created by Omer Emre Aslan on 25.03.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerTroubleshootBluetoothConnectionView: BaseView {
    private let layout = Layout<LayoutConstants>()
    
    private lazy var numberOneView: LedgerTutorialNumberView = {
        let numberView = LedgerTutorialNumberView()
        numberView.setNumber(1)
        numberView.setCornerRadius(16.0)
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
    
    override func configureAppearance() {
        backgroundColor = color("secondaryBackground")
        bindData()
    }
       
    override func prepareLayout() {
        setupNumberOneViewLayout()
        setupNumberOneTextViewLayout()
    }
}

extension LedgerTroubleshootBluetoothConnectionView {
    private func setupNumberOneViewLayout() {
        addSubview(numberOneView)
        
        numberOneView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.size.equalTo(layout.current.numberSize)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupNumberOneTextViewLayout() {
        addSubview(numberOneTextView)
        
        numberOneTextView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.leading.equalTo(numberOneView.snp.trailing).offset(layout.current.leadingInset)
            make.top.equalTo(numberOneView)
        }
    }
}

extension LedgerTroubleshootBluetoothConnectionView {
    private func bindData() {
        bindHtml("ledger-troubleshooting-bluetooth-connection-html".localized, to: numberOneTextView)
    }
    
    private func bindHtml(_ html: String?, to textView: UITextView) {
        guard let data = html?.data(using: .unicode),
            let attributedString = try? NSMutableAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil) else {
                return
        }
        
        attributedString.addAttributes(
            [
                NSAttributedString.Key.font: UIFont.font(.publicSans, withWeight: .regular(size: 14.0)),
                NSAttributedString.Key.foregroundColor: color("primaryText")
            ],
            range: NSRange(location: 0, length: attributedString.string.count)
        )
        textView.attributedText = attributedString
    }
}

extension LedgerTroubleshootBluetoothConnectionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let numberSize = CGSize(width: 32.0, height: 32.0)
        let topInset: CGFloat = 28.0
        let horizontalInset: CGFloat = 20.0
        let textViewOffset: CGFloat = 32.0
        let leadingInset: CGFloat = 16.0
    }
}
