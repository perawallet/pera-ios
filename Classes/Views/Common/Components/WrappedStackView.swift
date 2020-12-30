//
//  WrappedStackView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 15.12.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class WrappedStackView: BaseView {
    
    private(set) lazy var containerView = UIView()
    
    private(set) lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillProportionally
        stackView.spacing = 0.0
        stackView.alignment = .fill
        stackView.clipsToBounds = true
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stackView.axis = .vertical
        stackView.isUserInteractionEnabled = false
        return stackView
    }()
    
    override func configureAppearance() {
        super.configureAppearance()
        containerView.backgroundColor = Colors.Background.secondary
        containerView.layer.cornerRadius = 12.0
        containerView.layer.masksToBounds = true
    }
    
    override func prepareLayout() {
        setupContainerViewLayout()
        setupStackViewLayout()
    }
}

extension WrappedStackView {
    private func setupContainerViewLayout() {
        addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
    }
    
    private func setupStackViewLayout() {
        containerView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
    }
}

extension WrappedStackView {
    func addArrangedSubview(_ view: UIView) {
        stackView.addArrangedSubview(view)
    }
    
    func clear() {
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
}
