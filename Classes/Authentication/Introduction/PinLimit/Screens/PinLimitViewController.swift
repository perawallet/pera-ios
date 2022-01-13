// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  PinLimitViewController.swift

import UIKit

class PinLimitViewController: BaseViewController {
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    private var pinLimitStore = PinLimitStore()
    private var timer: PollingOperation?
    private var remainingTime = 0
    
    weak var delegate: PinLimitViewControllerDelegate?
    
    private lazy var bottomModalTransition = BottomSheetTransition(presentingViewController: self)
    
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
        view.backgroundColor = Colors.Background.tertiary
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
    
    override func linkInteractors() {
        pinLimitView.delegate = self
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

extension PinLimitViewController: PinLimitViewDelegate {
    func pinLimitViewDidResetAllData(_ pinLimitView: PinLimitView) {
        presentLogoutAlert()
    }
    
    private func presentLogoutAlert() {
        let bottomWarningViewConfigurator = BottomWarningViewConfigurator(
            image: "icon-settings-logout".uiImage,
            title: "settings-logout-title".localized,
            description: "settings-logout-detail".localized,
            primaryActionButtonTitle: "node-settings-action-delete-title".localized,
            secondaryActionButtonTitle: "title-cancel".localized,
            primaryAction: { [weak self] in
                guard let self = self else {
                    return
                }
                self.delegate?.pinLimitViewControllerDidResetAllData(self)
                self.dismissScreen()
            }
        )

        bottomModalTransition.perform(
            .bottomWarning(configurator: bottomWarningViewConfigurator),
            by: .presentWithoutNavigationController
        )
    }
}

protocol PinLimitViewControllerDelegate: AnyObject {
    func pinLimitViewControllerDidResetAllData(_ pinLimitViewController: PinLimitViewController)
}
