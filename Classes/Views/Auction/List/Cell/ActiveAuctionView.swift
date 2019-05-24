//
//  ActiveAuctionView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 15.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol ActiveAuctionViewDelegate: class {
    
    func activeAuctionViewDidTapEnterAuctionButton(_ activeAuctionView: ActiveAuctionView)
}

class ActiveAuctionView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let verticalInset: CGFloat = 25.0
        let horizontalInset: CGFloat = 5.0
        let titleContainerHeight: CGFloat = 37.0
        let auctionContainerHeight: CGFloat = 175.0
        let viewHeight: CGFloat = 85.0
        let viewWidth: CGFloat = UIScreen.main.bounds.width / 2
        let separatorHeight: CGFloat = 1.0
        let separatorInset: CGFloat = 20.0
        let buttonHeight: CGFloat = 56.0
        let buttonTopInset: CGFloat = 5.0
        let buttonInset: CGFloat = 26.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let separatorColor = rgb(0.95, 0.96, 0.96)
    }
    
    var status: AuctionStatus = .announced {
        didSet {
            if status == oldValue {
                return
            }
            
            configureView(for: status)
        }
    }
    
    // MARK: Components
    
    private lazy var titleContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = SharedColors.darkGray
        return view
    }()
    
    private(set) lazy var titleLabel: UILabel = {
        UILabel()
            .withTextColor(.white)
            .withLine(.single)
            .withAlignment(.center)
            .withFont(UIFont.font(.montserrat, withWeight: .semiBold(size: 12.0)))
            .withText("auction-scheduled-title".localized)
    }()
    
    private lazy var auctionContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private(set) lazy var dateView: DetailedInformationView = {
        let dateView = DetailedInformationView()
        dateView.backgroundColor = .white
        dateView.separatorView.isHidden = true
        dateView.explanationLabel.text = "auction-date-title".localized
        dateView.detailLabel.font = UIFont.font(.montserrat, withWeight: .semiBold(size: 14.0))
        return dateView
    }()
    
    private(set) lazy var auctionTimerView: AuctionTimerView = {
        let auctionTimerView = AuctionTimerView()
        return auctionTimerView
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    private(set) lazy var priceView: DetailedInformationView = {
        let priceView = DetailedInformationView()
        priceView.backgroundColor = .white
        priceView.separatorView.isHidden = true
        priceView.explanationLabel.text = "auction-starting-price".localized
        priceView.detailLabel.font = UIFont.font(.montserrat, withWeight: .semiBold(size: 14.0))
        return priceView
    }()
    
    private(set) lazy var remainingAlgosView: RemainingAlgosView = {
        let remainingAlgosView = RemainingAlgosView()
        return remainingAlgosView
    }()
    
    private(set) lazy var enterAuctionButton: UIButton = {
        UIButton(type: .custom)
            .withTitleColor(SharedColors.blue)
            .withTitle("auction-enter-title".localized)
            .withAlignment(.center)
            .withFont(UIFont.font(.montserrat, withWeight: .bold(size: 12.0)))
            .withBackgroundImage(img("bg-button-auction-enter"))
    }()
    
    private lazy var pastAuctionsTitleLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withTextColor(SharedColors.darkGray)
            .withFont(UIFont.font(.opensans, withWeight: .semiBold(size: 12.0)))
            .withText("auction-past-auctions".localized)
    }()
    
    weak var delegate: ActiveAuctionViewDelegate?
    
    // MARK: Setup
    
    override func setListeners() {
        enterAuctionButton.addTarget(self, action: #selector(notifyDelegateToEnterAuctionButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupTitleContainerViewLayout()
        setupTitleLabelLayout()
        setupAuctionContainerViewLayout()
        setupDateViewLayout()
        setupAuctionTimerViewLayout()
        setupSeparatorViewLayout()
        setupPriceViewLayout()
        setupRemainingAlgosViewLayout()
        setupEnterAuctionButtonLayout()
        setupPastAuctionsTitleLabelLayout()
    }
    
    private func setupTitleContainerViewLayout() {
        addSubview(titleContainerView)
        
        titleContainerView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(layout.current.titleContainerHeight)
        }
    }
    
    private func setupTitleLabelLayout() {
        titleContainerView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupAuctionContainerViewLayout() {
        addSubview(auctionContainerView)
        
        auctionContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(titleContainerView.snp.bottom)
        }
    }
    
    private func setupDateViewLayout() {
        auctionContainerView.addSubview(dateView)

        dateView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.width.equalTo(layout.current.viewWidth)
            make.height.equalTo(layout.current.viewHeight)
        }
    }
    
    private func setupAuctionTimerViewLayout() {
        auctionContainerView.addSubview(auctionTimerView)
        
        auctionTimerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.width.equalTo(layout.current.viewWidth)
            make.height.equalTo(layout.current.viewHeight)
        }
    }
    
    private func setupSeparatorViewLayout() {
        auctionContainerView.addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.separatorInset)
            make.height.equalTo(layout.current.separatorHeight)
            make.top.equalTo(dateView.snp.bottom)
        }
    }
    
    private func setupPriceViewLayout() {
        auctionContainerView.addSubview(priceView)

        priceView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.width.equalTo(layout.current.viewWidth)
            make.height.equalTo(layout.current.viewHeight)
        }
    }
    
    private func setupRemainingAlgosViewLayout() {
        auctionContainerView.addSubview(remainingAlgosView)
        
        remainingAlgosView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.width.equalTo(layout.current.viewWidth)
            make.height.equalTo(layout.current.viewHeight)
        }
    }
    
    private func setupEnterAuctionButtonLayout() {
        auctionContainerView.addSubview(enterAuctionButton)
        
        enterAuctionButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonInset)
            make.top.equalTo(priceView.snp.bottom).offset(layout.current.buttonTopInset)
            make.height.equalTo(layout.current.buttonHeight)
            make.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupPastAuctionsTitleLabelLayout() {
        addSubview(pastAuctionsTitleLabel)
        
        pastAuctionsTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.separatorInset)
            make.top.equalTo(auctionContainerView.snp.bottom).offset(layout.current.separatorInset)
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToEnterAuctionButtonTapped() {
        delegate?.activeAuctionViewDidTapEnterAuctionButton(self)
    }
    
    // MARK: Configuration
    
    private func configureView(for status: AuctionStatus) {
        switch status {
        case .announced:
            titleContainerView.backgroundColor = SharedColors.darkGray
            titleLabel.text = "auction-scheduled-title".localized
            priceView.explanationLabel.text = "auction-starting-price".localized
        case .running:
            titleContainerView.backgroundColor = SharedColors.green
            titleLabel.text = "auction-open-title".localized
            priceView.explanationLabel.text = "auction-current-price".localized
        case .closed:
            titleContainerView.backgroundColor = SharedColors.red
            titleLabel.text = "auction-closed-title".localized
            priceView.explanationLabel.text = "auction-closing-price".localized
        case .settled:
            titleContainerView.backgroundColor = SharedColors.red
            titleLabel.text = "auction-settled-title".localized
            priceView.explanationLabel.text = "auction-closing-price".localized
        }
    }
}
