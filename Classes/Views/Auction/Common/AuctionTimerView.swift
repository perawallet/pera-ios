//
//  AuctionTimerView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 15.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AuctionTimerView: BaseView {

    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 25.0
        let verticalInset: CGFloat = 20.0
        let labelTopInset: CGFloat = 10.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let black = rgb(0.03, 0.03, 0.03)
    }
    
    var mode: Mode = .initial {
        didSet {
            if mode == oldValue {
                return
            }
            
            DispatchQueue.main.async {
                self.configureTimerView()
            }
        }
    }
    
    var time: TimeInterval = 0
    
    private var isTimerRunning = false
    
    private var pollingOperation: PollingOperation?
    
    // MARK: Components
    
    private(set) lazy var explanationLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.opensans, withWeight: .semiBold(size: 12.0)))
            .withTextColor(SharedColors.softGray)
            .withAlignment(.left)
            .withText("auction-time-in".localized)
    }()
    
    private(set) lazy var timeLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.montserrat, withWeight: .semiBold(size: 14.0)))
            .withTextColor(Colors.black)
            .withLine(.single)
            .withAlignment(.left)
            .withText(formattedTime())
    }()
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    deinit {
        pollingOperation?.invalidate()
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupExplanationLabelLayout()
        setupTimeLabelLayout()
    }
    
    private func setupExplanationLabelLayout() {
        addSubview(explanationLabel)
        
        explanationLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.top.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupTimeLabelLayout() {
        addSubview(timeLabel)
        
        timeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.top.equalTo(explanationLabel.snp.bottom).offset(layout.current.labelTopInset)
            make.bottom.equalToSuperview().inset(layout.current.verticalInset)
            make.trailing.equalToSuperview().inset(layout.current.defaultInset)
        }
    }
    
    // MARK: API
    
    func runTimer() {
        if isTimerRunning {
            return
        }
        
        isTimerRunning = true
        
        timeLabel.text = formattedTime()
        
        pollingOperation = PollingOperation(interval: 1.0) { [weak self] in
            self?.updateTimer()
        }
        
        pollingOperation?.start()
    }
    
    func stopTimer() {
        isTimerRunning = false
        
        pollingOperation?.invalidate()
    }
    
    // MARK: Configuration
    
    @objc
    private func updateTimer() {
        if time == 0 {
            if mode == .initial {
                mode = .active
            } else if mode == .active {
                mode = .ended
            }
            
            return
        }
        
        time -= 1
        
        DispatchQueue.main.async {
            self.timeLabel.text = self.formattedTime()
        }
        
    }
    
    private func formattedTime() -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    private func configureTimerView() {
        switch mode {
        case .initial:
            explanationLabel.text = "auction-time-in".localized
            timeLabel.textColor = Colors.black
        case .active:
            explanationLabel.text = "auction-time-left".localized
            timeLabel.textColor = SharedColors.red
        case .ended:
            explanationLabel.text = "auction-time-left".localized
            timeLabel.textColor = SharedColors.black
            
            time = 0
            timeLabel.text = formattedTime()
            
            stopTimer()
        }
    }
}

// MARK: Mode

extension AuctionTimerView {
    
    enum Mode {
        case initial
        case active
        case ended
    }
}
