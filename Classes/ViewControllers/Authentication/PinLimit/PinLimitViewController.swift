//
//  PinLimitViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.06.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class PinLimitViewController: BaseViewController {
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    private var pinLimitStore = PinLimitStore()
    private var timer: PollingOperation?
    private var remainingTime = 0
    
    private lazy var pinLimitView = PinLimitView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializePinLimitCounter()
        startCountingForPinLimit()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    override func configureAppearance() {
        view.backgroundColor = SharedColors.secondaryBackground
    }
    
    override func setListeners() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(startCounterWhenBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(stopCounterInBackground),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    override func prepareLayout() {
        setupPinLimitViewLayout()
    }
}

extension PinLimitViewController {
    private func setupPinLimitViewLayout() {
        view.addSubview(pinLimitView)
        
        pinLimitView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension PinLimitViewController {
    @objc
    private func startCounterWhenBecomeActive() {
        remainingTime = pinLimitStore.remainingTime
        startCountingForPinLimit()
    }
    
    @objc
    private func stopCounterInBackground() {
        stopCountingForPinLimit()
    }
}

extension PinLimitViewController {
    private func calculateAndSetRemainingTime() {        
        if let remainingTimeInString = remainingTime.convertSecondsToHoursMinutesSeconds() {
            self.pinLimitView.setCounterText(remainingTimeInString)
        }
        
        remainingTime -= 1
        
        if remainingTime <= 0 {
            self.pinLimitStore.setRemainingTime(0)
            self.closeScreen(by: .dismiss, animated: false)
        }
    }
    
    private func initializePinLimitCounter() {
        remainingTime = pinLimitStore.remainingTime
        if let remainingTimeInString = remainingTime.convertSecondsToHoursMinutesSeconds() {
            pinLimitView.setCounterText(remainingTimeInString)
        }
    }
    
    private func startCountingForPinLimit() {
        timer = PollingOperation(interval: 1.0) { [weak self] in
            DispatchQueue.main.async {
                self?.calculateAndSetRemainingTime()
            }
        }
        
        timer?.start()
    }
    
    private func stopCountingForPinLimit() {
        pinLimitStore.setRemainingTime(remainingTime)
        timer?.invalidate()
    }
}
