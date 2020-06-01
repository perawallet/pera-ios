//
//  TermsAndServicesView.swift
//  algorand
//
//  Created by Omer Emre Aslan on 27.03.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

protocol TermsAndServicesViewDelegate: class {
    func termsAndServicesView(_ view: TermsAndServicesView, didTap url: URL)
    func termsAndServicesViewDidCheck(_ view: TermsAndServicesView)
}

class TermsAndServicesView: BaseView {
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withTextColor(SharedColors.primaryText)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withAttributedText("terms-and-services-title".localized.uppercased().attributed([.letterSpacing(1.07)]))
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = rgb(0.91, 0.91, 0.92)
        return view
    }()
    
    private lazy var checkbox: Checkbox = {
        Checkbox()
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = .link
        textView.textContainerInset = .zero
        textView.backgroundColor = .clear
        return textView
    }()
    
    weak var delegate: TermsAndServicesViewDelegate?
    
    override func prepareLayout() {
        super.prepareLayout()
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { maker in
            maker.top.equalToSuperview().inset(33)
            maker.centerX.equalToSuperview()
        }
        
        addSubview(separatorView)
        separatorView.snp.makeConstraints { maker in
            maker.top.equalTo(titleLabel.snp.bottom).offset(18)
            maker.leading.trailing.equalToSuperview().inset(25)
            maker.height.equalTo(1)
        }
        
        addSubview(checkbox)
        checkbox.snp.makeConstraints { maker in
            maker.top.equalTo(separatorView.snp.bottom).offset(28)
            maker.leading.equalToSuperview().inset(30)
            maker.height.width.equalTo(24)
        }
        
        addSubview(textView)
        textView.snp.makeConstraints { maker in
            maker.leading.equalTo(checkbox.snp.trailing).offset(10)
            maker.centerY.equalTo(checkbox)
            maker.height.equalTo(20)
        }
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        backgroundColor = .white
        bindData()
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        
        textView.delegate = self
        checkbox.addTarget(self, action: #selector(didTapCheckbox), for: .touchUpInside)
    }
}

// MARK: Data Binding
extension TermsAndServicesView {
    private func bindData() {
        bindHtml("terms-and-services-html".localized, to: textView)
    }
    
    private func bindHtml(_ html: String?, to textView: UITextView) {
        guard let data = html?.data(using: .unicode),
            let attributedString = try? NSMutableAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil) else {
                return
        }
        
        attributedString.addAttributes([NSAttributedString.Key.font: UIFont.font(withWeight: .medium(size: 14.0)),
                                        NSAttributedString.Key.foregroundColor: SharedColors.primaryText],
                                       range: NSRange(location: 0, length: attributedString.string.count))
        textView.attributedText = attributedString
    }
}

// MARK: UITextViewDelegate
extension TermsAndServicesView: UITextViewDelegate {
    func textView(_ textView: UITextView,
                  shouldInteractWith URL: URL,
                  in characterRange: NSRange,
                  interaction: UITextItemInteraction) -> Bool {
        delegate?.termsAndServicesView(self, didTap: URL)
        return false
    }
}

// MARK: Checkbox
extension TermsAndServicesView {
    @objc
    private func didTapCheckbox() {
        checkbox.isSelected.toggle()
        
        delegate?.termsAndServicesViewDidCheck(self)
    }
}
