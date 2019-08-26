//
//  HistoryView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol HistoryViewDelegate: class {
    
    func historyViewDidTapViewResultsButton(_ historyView: HistoryView)
    func historyViewDidTapAccountSelectionView(_ historyView: HistoryView)
}

class HistoryView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let bottomInset: CGFloat = 75.0
        let buttonMinimumInset: CGFloat = 60.0
        let buttonHorizontalInset: CGFloat = MainButton.Constants.horizontalInset
    }
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: HistoryViewDelegate?
    
    var startDate: Date = Date().dateByAdding(-1, .weekOfYear).date
    var endDate: Date = Date()
    
    // MARK: Components
    
    private(set) lazy var accountSelectionView: AccountSelectionView = {
        let accountSelectionView = AccountSelectionView()
        accountSelectionView.backgroundColor = .clear
        accountSelectionView.explanationLabel.text = "history-account".localized
        return accountSelectionView
    }()
    
    private(set) lazy var startDateDisplayView: DetailedInformationView = {
        let startDateDisplayView = DetailedInformationView()
        startDateDisplayView.backgroundColor = .clear
        startDateDisplayView.explanationLabel.text = "history-start-date".localized
        startDateDisplayView.isUserInteractionEnabled = true
        startDateDisplayView.detailLabel.font = UIFont.font(.overpass, withWeight: .semiBold(size: 14.0))
        startDateDisplayView.detailLabel.text = startDate.toFormat("dd MMMM yyyy")
        return startDateDisplayView
    }()
    
    private(set) lazy var startDatePickerView: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.isHidden = true
        datePicker.date = startDate
        return datePicker
    }()
    
    private(set) lazy var endDateDisplayView: DetailedInformationView = {
        let endDateDisplayView = DetailedInformationView()
        endDateDisplayView.backgroundColor = .clear
        endDateDisplayView.explanationLabel.text = "history-end-date".localized
        endDateDisplayView.isUserInteractionEnabled = true
        endDateDisplayView.detailLabel.font = UIFont.font(.overpass, withWeight: .semiBold(size: 14.0))
        endDateDisplayView.detailLabel.text = endDate.toFormat("dd MMMM yyyy")
        return endDateDisplayView
    }()
    
    private(set) lazy var endDatePickerView: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.isHidden = true
        datePicker.date = endDate
        return datePicker
    }()

    private(set) lazy var viewResultsButton = MainButton(title: "title-view-results".localized)
    
    // MARK: Gestures

    private lazy var accountSelectionGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(notifyDelegateToAccountSelectionViewTapped)
    )
    
    private lazy var startDateTapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(didTriggerStartDate(tapGestureRecognizer:))
    )
    
    private lazy var endDateTapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(didTriggerEndDate(tapGestureRecognizer:))
    )
    
    // MARK: Setup
    
    override func linkInteractors() {
        viewResultsButton.addTarget(self, action: #selector(notifyDelegateToViewResultsButtonTapped), for: .touchUpInside)
        accountSelectionView.addGestureRecognizer(accountSelectionGestureRecognizer)
        startDateDisplayView.addGestureRecognizer(startDateTapGestureRecognizer)
        endDateDisplayView.addGestureRecognizer(endDateTapGestureRecognizer)
        
        startDatePickerView.addTarget(self, action: #selector(didChangeStartDate(picker:)), for: .valueChanged)
        endDatePickerView.addTarget(self, action: #selector(didChangeEndDate(picker:)), for: .valueChanged)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupAccountSelectionViewLayout()
        setupStartDateDisplayViewLayout()
        setupEndDateDisplayViewLayout()
        setupStartDatePickerViewLayout()
        setupEndDatePickerViewLayout()
        setupViewResultsButtonLayout()
    }
    
    private func setupAccountSelectionViewLayout() {
        addSubview(accountSelectionView)
        
        accountSelectionView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
        }
    }
    
    private func setupStartDateDisplayViewLayout() {
        addSubview(startDateDisplayView)
        
        startDateDisplayView.snp.makeConstraints { make in
            make.top.equalTo(accountSelectionView.snp.bottom)
            make.leading.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width / 2)
        }
    }

    private func setupEndDateDisplayViewLayout() {
        addSubview(endDateDisplayView)
        
        endDateDisplayView.snp.makeConstraints { make in
            make.top.equalTo(accountSelectionView.snp.bottom)
            make.trailing.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width / 2)
        }
    }
    
    private func setupStartDatePickerViewLayout() {
        addSubview(startDatePickerView)
        
        startDatePickerView.snp.makeConstraints { make in
            make.top.equalTo(startDateDisplayView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0.0)
        }
    }
    
    private func setupEndDatePickerViewLayout() {
        addSubview(endDatePickerView)
        
        endDatePickerView.snp.makeConstraints { make in
            make.top.equalTo(endDateDisplayView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0.0)
        }
    }
    
    private func setupViewResultsButtonLayout() {
        addSubview(viewResultsButton)
        
        viewResultsButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(endDatePickerView.snp.bottom).offset(layout.current.buttonMinimumInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
            make.bottom.equalToSuperview().inset(safeAreaBottom + layout.current.bottomInset)
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToViewResultsButtonTapped() {
        delegate?.historyViewDidTapViewResultsButton(self)
    }
    
    @objc
    private func notifyDelegateToAccountSelectionViewTapped() {
        delegate?.historyViewDidTapAccountSelectionView(self)
    }
    
    @objc
    private func didChangeStartDate(picker: UIDatePicker) {
        if picker.date > Date() {
            guard let topViewController = UIApplication.topViewController() else {
                return
            }
            
            topViewController.displaySimpleAlertWith(title: "title-error".localized, message: "history-future-date-error".localized)
            
            startDatePickerView.date = startDate
            return
        }
        
        startDate = picker.date
        
        startDateDisplayView.detailLabel.text = startDate.toFormat("dd MMMM yyyy")
    }
    
    @objc
    private func didChangeEndDate(picker: UIDatePicker) {
        if picker.date > Date() {
            guard let topViewController = UIApplication.topViewController() else {
                return
            }
            
            topViewController.displaySimpleAlertWith(title: "title-error".localized, message: "history-future-date-error".localized)
            
            endDatePickerView.date = endDate
            return
        }
        
        if startDate > picker.date {
            guard let topViewController = UIApplication.topViewController() else {
                return
            }
            
            topViewController.displaySimpleAlertWith(title: "title-error".localized, message: "history-end-date-error".localized)
            
            endDatePickerView.date = endDate
            return
        }
        
        endDate = picker.date
        
        endDateDisplayView.detailLabel.text = endDate.toFormat("dd MMMM yyyy")
    }
    
    @objc
    private func didTriggerStartDate(tapGestureRecognizer: UITapGestureRecognizer) {
        if startDatePickerView.isHidden {
            startDate = startDatePickerView.date
            startDateDisplayView.detailLabel.text = startDate.toFormat("dd MMMM yyyy")
            
            setStartDatePicker(visible: true)
        } else {
            setStartDatePicker(visible: false)
        }
    }
    
    @objc
    private func didTriggerEndDate(tapGestureRecognizer: UITapGestureRecognizer) {
        if endDatePickerView.isHidden {
            endDate = endDatePickerView.date
            endDateDisplayView.detailLabel.text = endDate.toFormat("dd MMMM yyyy")
            
            setEndDatePicker(visible: true)
        } else {
            setEndDatePicker(visible: false)
        }
    }
    
    // MARK: API
    
    private func setStartDatePicker(visible: Bool) {
        if visible {
            if !endDatePickerView.isHidden {
                endDatePickerView.isHidden = true
                
                endDatePickerView.snp.updateConstraints { make in
                    make.height.equalTo(0.0)
                }
                
                UIView.animate(withDuration: 0.3) {
                    self.layoutIfNeeded()
                }
            }
            
            startDatePickerView.isHidden = false
            
            startDatePickerView.snp.updateConstraints { make in
                make.height.equalTo(216.0)
            }
            
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        } else {
            startDatePickerView.snp.updateConstraints { make in
                make.height.equalTo(0.0)
            }
            
            UIView.animate(withDuration: 0.3) {
                self.startDatePickerView.isHidden = true
                
                self.layoutIfNeeded()
            }
        }
    }
    
    private func setEndDatePicker(visible: Bool) {
        if visible {
            if !startDatePickerView.isHidden {
                startDatePickerView.isHidden = true
                
                startDatePickerView.snp.updateConstraints { make in
                    make.height.equalTo(0.0)
                }
                
                UIView.animate(withDuration: 0.3) {
                    self.layoutIfNeeded()
                }
            }
            
            endDatePickerView.isHidden = false
            
            endDatePickerView.snp.updateConstraints { make in
                make.height.equalTo(216.0)
            }
            
            UIView.animate(withDuration: 0.3) {
                
                self.layoutIfNeeded()
            }
        } else {
            endDatePickerView.snp.updateConstraints { make in
                make.height.equalTo(0.0)
            }
            
            UIView.animate(withDuration: 0.3) {
                self.endDatePickerView.isHidden = true
                
                self.layoutIfNeeded()
            }
        }
    }
}
