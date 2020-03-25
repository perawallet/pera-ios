//
//  LedgerTroubleshootBluetoothConnectionView.swift
//  algorand
//
//  Created by Omer Emre Aslan on 25.03.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerTroubleshootBluetoothConnectionView: BaseView {
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
        if let htmlData = "ledger-troubleshooting-bluetooth-connection-html".localized.data(using: .unicode),
            let attributedString = try? NSMutableAttributedString(
                data: htmlData,
                options: [.documentType: NSAttributedString.DocumentType.html],
                documentAttributes: nil) {
            
            attributedString.addAttributes([NSAttributedString.Key.font: UIFont.font(.avenir, withWeight: .medium(size: 14.0)),
                                            NSAttributedString.Key.foregroundColor: SharedColors.black],
                                           range: NSRange(location: 0, length: attributedString.string.count))
            textView.attributedText = attributedString
        }
        return textView
    }()
    
    override func configureAppearance() {
        backgroundColor = .white
    }
       
    override func prepareLayout() {
        setupFirstTutorialLayout()
    }
}

// MARK: Layout
extension LedgerTroubleshootBluetoothConnectionView {
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
            maker.height.equalTo(200)
        }
    }
}
