//
//  AuctionSliderView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 17.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AuctionSliderViewDelegate: class {
    
    func auctionSliderView(_ auctionSliderView: AuctionSliderView, didChange value: Float)
}

class AuctionSliderView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let sliderHorizontalInset: CGFloat = 20.0
        let sliderTopInset: CGFloat = 28.0
        let buttonTopInset: CGFloat = 5.0
        let buttonLeadingInset: CGFloat = 14.0
        let buttonOffset: CGFloat = (UIScreen.main.bounds.width - 210.0) / 4
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
            .withTitleColor(SharedColors.softGray)
            .withAlignment(.center)
            .withFont(UIFont.font(.montserrat, withWeight: .bold(size: 9.0)))
            .withTitle("0%")
    }()
    
    private lazy var twentyFivePercentButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundColor(.white)
            .withTitleColor(SharedColors.softGray)
            .withAlignment(.center)
            .withFont(UIFont.font(.montserrat, withWeight: .bold(size: 9.0)))
            .withTitle("25%")
    }()

    private lazy var fiftyPercentButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundColor(.white)
            .withTitleColor(SharedColors.softGray)
            .withAlignment(.center)
            .withFont(UIFont.font(.montserrat, withWeight: .bold(size: 9.0)))
            .withTitle("50%")
    }()
    
    private lazy var seventyFivePercentButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundColor(.white)
            .withTitleColor(SharedColors.softGray)
            .withAlignment(.center)
            .withFont(UIFont.font(.montserrat, withWeight: .bold(size: 9.0)))
            .withTitle("75%")
    }()
    
    private lazy var hundredPercentButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundColor(.white)
            .withTitleColor(SharedColors.softGray)
            .withAlignment(.center)
            .withFont(UIFont.font(.montserrat, withWeight: .bold(size: 9.0)))
            .withTitle("100%")
    }()
    
    weak var delegate: AuctionSliderViewDelegate?
    
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
            make.top.equalToSuperview().inset(layout.current.sliderTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.sliderHorizontalInset)
        }
    }
    
    private func setupZeroPercentButtonLayout() {
        addSubview(zeroPercentButton)
        
        zeroPercentButton.snp.makeConstraints { make in
            make.top.equalTo(sliderView.snp.bottom).offset(layout.current.buttonTopInset)
            make.leading.equalToSuperview().inset(layout.current.buttonLeadingInset)
        }
    }
    
    private func setupTwentyFivePercentButtonLayout() {
        addSubview(twentyFivePercentButton)
        
        twentyFivePercentButton.snp.makeConstraints { make in
            make.top.equalTo(zeroPercentButton)
            make.leading.equalTo(zeroPercentButton.snp.trailing).offset(layout.current.buttonOffset)
        }
    }
    
    private func setupFiftyPercentButtonLayout() {
        addSubview(fiftyPercentButton)
        
        fiftyPercentButton.snp.makeConstraints { make in
            make.top.equalTo(zeroPercentButton)
            make.leading.equalTo(twentyFivePercentButton.snp.trailing).offset(layout.current.buttonOffset)
        }
    }
    
    private func setupSeventyFivePercentButtonLayout() {
        addSubview(seventyFivePercentButton)
        
        seventyFivePercentButton.snp.makeConstraints { make in
            make.top.equalTo(zeroPercentButton)
            make.leading.equalTo(fiftyPercentButton.snp.trailing).offset(layout.current.buttonOffset)
        }
    }
    
    private func setupHundredPercentButtonLayout() {
        addSubview(hundredPercentButton)
        
        hundredPercentButton.snp.makeConstraints { make in
            make.top.equalTo(zeroPercentButton)
            make.leading.equalTo(seventyFivePercentButton.snp.trailing).offset(layout.current.buttonOffset)
        }
    }
    
    // MARK: Actions
    
    @objc
    private func percentageButtonDidTap(button: UIButton) {
        switch button {
        case zeroPercentButton:
            configureViewForZeroPercentValue(updatesSliderValue: true)
        case twentyFivePercentButton:
            configureViewForTwentyFivePercentValue(updatesSliderValue: true)
        case fiftyPercentButton:
            configureViewForFiftyPercentValue(updatesSliderValue: true)
        case seventyFivePercentButton:
            configureViewForSeventyFivePercentValue(updatesSliderValue: true)
        case hundredPercentButton:
            configureViewForHundredPercentValue(updatesSliderValue: true)
        default:
            break
        }
    }
    
    private func configureViewForZeroPercentValue(updatesSliderValue: Bool = false) {
        if updatesSliderValue {
            sliderView.value = 0
            delegate?.auctionSliderView(self, didChange: sliderView.value)
            sliderView.setThumbImage(img("icon-slider-zero"), for: .normal)
        }
        
        zeroPercentButton.setTitleColor(SharedColors.softGray, for: .normal)
        twentyFivePercentButton.setTitleColor(SharedColors.softGray, for: .normal)
        fiftyPercentButton.setTitleColor(SharedColors.softGray, for: .normal)
        seventyFivePercentButton.setTitleColor(SharedColors.softGray, for: .normal)
        hundredPercentButton.setTitleColor(SharedColors.softGray, for: .normal)
    }
    
    private func configureViewForTwentyFivePercentValue(updatesSliderValue: Bool = false) {
        if updatesSliderValue {
            sliderView.value = 25
            delegate?.auctionSliderView(self, didChange: sliderView.value)
            sliderView.setThumbImage(img("icon-slider-selected"), for: .normal)
        }
        
        zeroPercentButton.setTitleColor(SharedColors.blue, for: .normal)
        twentyFivePercentButton.setTitleColor(SharedColors.blue, for: .normal)
        fiftyPercentButton.setTitleColor(SharedColors.softGray, for: .normal)
        seventyFivePercentButton.setTitleColor(SharedColors.softGray, for: .normal)
        hundredPercentButton.setTitleColor(SharedColors.softGray, for: .normal)
    }
    
    private func configureViewForFiftyPercentValue(updatesSliderValue: Bool = false) {
        if updatesSliderValue {
            sliderView.value = 50
            delegate?.auctionSliderView(self, didChange: sliderView.value)
            sliderView.setThumbImage(img("icon-slider-selected"), for: .normal)
        }
        
        zeroPercentButton.setTitleColor(SharedColors.blue, for: .normal)
        twentyFivePercentButton.setTitleColor(SharedColors.blue, for: .normal)
        fiftyPercentButton.setTitleColor(SharedColors.blue, for: .normal)
        seventyFivePercentButton.setTitleColor(SharedColors.softGray, for: .normal)
        hundredPercentButton.setTitleColor(SharedColors.softGray, for: .normal)
    }
    
    private func configureViewForSeventyFivePercentValue(updatesSliderValue: Bool = false) {
        if updatesSliderValue {
            sliderView.value = 75
            delegate?.auctionSliderView(self, didChange: sliderView.value)
            sliderView.setThumbImage(img("icon-slider-selected"), for: .normal)
        }
        
        zeroPercentButton.setTitleColor(SharedColors.blue, for: .normal)
        twentyFivePercentButton.setTitleColor(SharedColors.blue, for: .normal)
        fiftyPercentButton.setTitleColor(SharedColors.blue, for: .normal)
        seventyFivePercentButton.setTitleColor(SharedColors.blue, for: .normal)
        hundredPercentButton.setTitleColor(SharedColors.softGray, for: .normal)
    }
    
    private func configureViewForHundredPercentValue(updatesSliderValue: Bool = false) {
        if updatesSliderValue {
            sliderView.value = 100
            delegate?.auctionSliderView(self, didChange: sliderView.value)
            sliderView.setThumbImage(img("icon-slider-selected"), for: .normal)
        }
        
        zeroPercentButton.setTitleColor(SharedColors.blue, for: .normal)
        twentyFivePercentButton.setTitleColor(SharedColors.blue, for: .normal)
        fiftyPercentButton.setTitleColor(SharedColors.blue, for: .normal)
        seventyFivePercentButton.setTitleColor(SharedColors.blue, for: .normal)
        hundredPercentButton.setTitleColor(SharedColors.blue, for: .normal)
    }
    
    @objc
    private func sliderDidChangeValue(sliderView: AuctionSlider) {
        delegate?.auctionSliderView(self, didChange: sliderView.value)
        
        if sliderView.value == 0 {
            sliderView.setThumbImage(img("icon-slider-zero"), for: .normal)
            configureViewForZeroPercentValue()
            return
        }
        
        sliderView.setThumbImage(img("icon-slider-selected"), for: .normal)
        
        if sliderView.value == 100 {
            configureViewForHundredPercentValue()
            return
        }
        
        if sliderView.value >= 75 {
            configureViewForSeventyFivePercentValue()
            return
        }
        
        if sliderView.value >= 50 {
            configureViewForFiftyPercentValue()
            return
        }
        
        if sliderView.value >= 25 {
            configureViewForTwentyFivePercentValue()
            return
        }
        
        if sliderView.value >= 1 {
            configureViewForMoreThanZeroValue()
            return
        }
    }
    
    private func configureViewForMoreThanZeroValue() {
        zeroPercentButton.setTitleColor(SharedColors.blue, for: .normal)
        twentyFivePercentButton.setTitleColor(SharedColors.softGray, for: .normal)
        fiftyPercentButton.setTitleColor(SharedColors.softGray, for: .normal)
        seventyFivePercentButton.setTitleColor(SharedColors.softGray, for: .normal)
        hundredPercentButton.setTitleColor(SharedColors.softGray, for: .normal)
    }
}
