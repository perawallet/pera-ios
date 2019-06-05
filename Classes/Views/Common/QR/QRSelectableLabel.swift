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
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 13.0)))
            .withAlignment(.center)
            .withTextColor(SharedColors.black)
            .withLine(.multi(2))
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 10
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        UIImageView(image: img("icon-copy"))
    }()
    
    private lazy var copyLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 12.0)))
            .withTextColor(SharedColors.softGray)
            .withText("qr-creation-tap-to-copy".localized)
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
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(80)
        }
        
        containerView.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
        }
        
        addSubview(copyLabel)
        copyLabel.snp.makeConstraints { make in
            make.centerX.equalTo(containerView).offset(3)
            make.top.equalTo(containerView.snp.bottom).offset(6)
        }
        
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.centerY.equalTo(copyLabel)
            make.trailing.equalTo(copyLabel.snp.leading).offset(-5)
        }
    }
    
    fileprivate func setupGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap(gesture:)))
        self.addGestureRecognizer(tapGestureRecognizer)
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
        
        self.copyLabel.text = "qr-creation-copied".localized
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.copyLabel.text = "qr-creation-tap-to-copy".localized
        }
    }
}
