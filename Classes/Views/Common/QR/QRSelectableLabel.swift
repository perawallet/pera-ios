//
//  QRSelectableLabel.swift
//  algorand
//
//  Created by Omer Emre Aslan on 1.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol QRSelectableLabelDelegate: class {
    func qrSelectableLabel(_ qrSelectableLabel: QRSelectableLabel,
                           didTapText text: String)
}

class QRSelectableLabel: UIView {
    private(set) lazy var label: UILabel = {
        UILabel()
            .withFont(UIFont.font(.montserrat, withWeight: .semiBold(size: 13.0)))
            .withAlignment(.center)
            .withTextColor(UIColor(hex: "#0B0E13"))
            .withLine(.multi(2))
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 10
        return view
    }()
    
    weak var delegate: QRSelectableLabelDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupGesture()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout
extension QRSelectableLabel {
    fileprivate func setupLayout() {
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
        }
    }
    
    fileprivate func setupGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap(gesture:)))
        containerView.addGestureRecognizer(tapGestureRecognizer)
    }
}

// MARK: - Actions
extension QRSelectableLabel {
    @objc
    fileprivate func tap(gesture recognizer: UIGestureRecognizer) {
        guard let delegate = delegate,
            let text = label.text else {
            return
        }
        
        delegate.qrSelectableLabel(self, didTapText: text)
    }
}
