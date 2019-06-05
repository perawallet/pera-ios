//
//  AuctionSliderView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 17.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AuctionSliderView: BaseView {
    
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
    
    // MARK: Components
    
    private lazy var sliderView: AuctionSlider = {
        let slider = AuctionSlider()
        return slider
    }()
    
    private lazy var zeroPercentButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundColor(.white)
            .withTitleColor(SharedColors.turquois)
            .withAlignment(.center)
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 9.0)))
            .withTitle("0%")
    }()
    
    private lazy var twentyFivePercentButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundColor(.white)
            .withTitleColor(SharedColors.turquois)
            .withAlignment(.center)
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 9.0)))
            .withTitle("25%")
    }()

    private lazy var fiftyPercentButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundColor(.white)
            .withTitleColor(SharedColors.turquois)
            .withAlignment(.center)
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 9.0)))
            .withTitle("50%")
    }()
    
    private lazy var seventyFivePercentButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundColor(.white)
            .withTitleColor(SharedColors.turquois)
            .withAlignment(.center)
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 9.0)))
            .withTitle("75%")
    }()
    
    private lazy var hundredPercentButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundColor(.white)
            .withTitleColor(SharedColors.turquois)
            .withAlignment(.center)
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 9.0)))
            .withTitle("100%")
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    override func setListeners() {
        zeroPercentButton.addTarget(self, action: #selector(percentageButtonDidTap(button:)), for: .touchUpInside)
        twentyFivePercentButton.addTarget(self, action: #selector(percentageButtonDidTap(button:)), for: .touchUpInside)
        fiftyPercentButton.addTarget(self, action: #selector(percentageButtonDidTap(button:)), for: .touchUpInside)
        seventyFivePercentButton.addTarget(self, action: #selector(percentageButtonDidTap(button:)), for: .touchUpInside)
        hundredPercentButton.addTarget(self, action: #selector(percentageButtonDidTap(button:)), for: .touchUpInside)
        
        sliderView.addTarget(self, action: #selector(sliderDidChangeValue(sliderView:)), for: .valueChanged)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupSliderViewLayout()
        setupZeroPercentButtonLayout()
        setupTwentyFivePercentButtonLayout()
        setupFiftyPercentButtonLayout()
        setupSeventyFivePercentButtonLayout()
        setupHundredPercentButtonLayout()
    }
    
    private func setupSliderViewLayout() {
        addSubview(sliderView)
        
        sliderView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupZeroPercentButtonLayout() {
        addSubview(zeroPercentButton)
        
        zeroPercentButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupTwentyFivePercentButtonLayout() {
        addSubview(twentyFivePercentButton)
        
        twentyFivePercentButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupFiftyPercentButtonLayout() {
        addSubview(fiftyPercentButton)
        
        fiftyPercentButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupSeventyFivePercentButtonLayout() {
        addSubview(seventyFivePercentButton)
        
        seventyFivePercentButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupHundredPercentButtonLayout() {
        addSubview(hundredPercentButton)
        
        hundredPercentButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
    }
    
    // MARK: Actions
    
    @objc
    private func percentageButtonDidTap(button: UIButton) {
        switch button {
        case zeroPercentButton:
            break
        case twentyFivePercentButton:
            break
        case fiftyPercentButton:
            break
        case seventyFivePercentButton:
            break
        case hundredPercentButton:
            break
        default:
            break
        }
    }
    
    @objc
    private func sliderDidChangeValue(sliderView: AuctionSlider) {
        
    }
}
