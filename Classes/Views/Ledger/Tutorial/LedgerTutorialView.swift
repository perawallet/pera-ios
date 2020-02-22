//
//  LedgerTutorialView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerTutorialView: BaseView {

    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: LedgerTutorialViewDelegate?
    
    private lazy var imageBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var ledgerDeviceImageView = UIImageView(image: img("img-ledger-device"))
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withLine(.contained)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 12.0)))
            .withText("ledger-tutorial-title-text".localized)
            .withAlignment(.center)
            .withTextColor(SharedColors.darkGray)
    }()
    
    private lazy var ledgerTutorialInstructionListView = LedgerTutorialInstructionListView()
    
    private lazy var searchButton = MainButton(title: "ledger-search-button-title".localized)
    
    override func configureAppearance() {
        super.configureAppearance()
        setImageBackgroundViewShadow()
    }
    
    override func setListeners() {
        searchButton.addTarget(self, action: #selector(notifyDelegateToSearchLedgerDevices), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupImageBackgroundViewLayout()
        setupLedgerDeviceImageViewLayout()
        setupTitleLabelLayout()
        setupLedgerTutorialInstructionListViewLayout()
        setupSearchButtonLayout()
    }
}

extension LedgerTutorialView {
    @objc
    private func notifyDelegateToSearchLedgerDevices() {
        delegate?.ledgerTutorialViewDidTapSearchButton(self)
    }
}

extension LedgerTutorialView {
    private func setupImageBackgroundViewLayout() {
        addSubview(imageBackgroundView)
        
        imageBackgroundView.layer.cornerRadius = layout.current.imageBackgroundViewSize.width / 2
        
        imageBackgroundView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.imageBackgroundViewTopInset)
            make.size.equalTo(layout.current.imageBackgroundViewSize)
        }
    }
    
    private func setupLedgerDeviceImageViewLayout() {
        imageBackgroundView.addSubview(ledgerDeviceImageView)
        
        ledgerDeviceImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageBackgroundView.snp.bottom).offset(layout.current.titleTopInset)
        }
    }
    
    private func setupLedgerTutorialInstructionListViewLayout() {
        addSubview(ledgerTutorialInstructionListView)
        
        ledgerTutorialInstructionListView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.imageBackgroundViewTopInset)
        }
    }
    
    private func setupSearchButtonLayout() {
        addSubview(searchButton)
        
        searchButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.greaterThanOrEqualTo(ledgerTutorialInstructionListView.snp.bottom).offset(layout.current.buttonMinimumTopInset)
            make.bottom.equalToSuperview().inset(layout.current.buttonBottomInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
        }
    }
}

extension LedgerTutorialView {
    private func setImageBackgroundViewShadow() {
        imageBackgroundView.layer.shadowColor = Colors.shadowColor.cgColor
        imageBackgroundView.layer.shadowOpacity = 1.0
        imageBackgroundView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        imageBackgroundView.layer.shadowRadius = 4.0
    }
}

extension LedgerTutorialView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let imageBackgroundViewSize = CGSize(width: 127.0, height: 127.0)
        let imageBackgroundViewTopInset: CGFloat = 60.0
        let buttonHorizontalInset: CGFloat = MainButton.Constants.horizontalInset
        let buttonBottomInset: CGFloat = 60.0
        let titleTopInset: CGFloat = 16.0
        let buttonMinimumTopInset: CGFloat = 20.0
    }
}

extension LedgerTutorialView {
    private enum Colors {
        static let shadowColor = rgb(0.91, 0.91, 0.95)
    }
}

protocol LedgerTutorialViewDelegate: class {
    func ledgerTutorialViewDidTapSearchButton(_ ledgerTutorialView: LedgerTutorialView)
}
