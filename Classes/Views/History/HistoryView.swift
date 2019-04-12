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
        let topInset: CGFloat = 5.0
        let horizontalInset: CGFloat = 20.0
        let algosAmountTopInset: CGFloat = 55.0
        let bottomInset: CGFloat = 75.0
        let buttonMinimumInset: CGFloat = 60.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: HistoryViewDelegate?
    
    var startDate: Date?
    var endDate: Date?
    
    // MARK: Components

    private(set) lazy var accountSelectionView: DetailedInformationView = {
        let accountSelectionView = DetailedInformationView()
        accountSelectionView.isUserInteractionEnabled = true
        accountSelectionView.backgroundColor = .white
        accountSelectionView.rightInputAccessoryButton.setImage(img("icon-arrow"), for: .normal)
        accountSelectionView.explanationLabel.text = "history-account".localized
        accountSelectionView.detailLabel.text = "send-algos-select".localized
        accountSelectionView.detailLabel.font = UIFont.font(.montserrat, withWeight: .semiBold(size: 12.0))
        return accountSelectionView
    }()
    
    private(set) lazy var startDateDisplayView: DetailedInformationView = {
        let startDateDisplayView = DetailedInformationView()
        startDateDisplayView.backgroundColor = .white
        startDateDisplayView.explanationLabel.text = "history-start-date".localized
        startDateDisplayView.detailLabel.text = "history-select-date".localized
        startDateDisplayView.isUserInteractionEnabled = true
        startDateDisplayView.detailLabel.font = UIFont.font(.montserrat, withWeight: .semiBold(size: 12.0))
        return startDateDisplayView
    }()
    
    private(set) lazy var accountAmountView: AlgosAmountView = {
        let view = AlgosAmountView()
        view.isHidden = true
        view.signLabel.isHidden = true
        return view
    }()
    
    private(set) lazy var startDatePickerView: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.isHidden = true
        datePicker.maximumDate = Date()
        return datePicker
    }()
    
    private(set) lazy var endDateDisplayView: DetailedInformationView = {
        let endDateDisplayView = DetailedInformationView()
        endDateDisplayView.backgroundColor = .white
        endDateDisplayView.explanationLabel.text = "history-end-date".localized
        endDateDisplayView.detailLabel.text = "history-select-date".localized
        endDateDisplayView.isUserInteractionEnabled = true
        endDateDisplayView.detailLabel.font = UIFont.font(.montserrat, withWeight: .semiBold(size: 12.0))
        return endDateDisplayView
    }()
    
    private(set) lazy var endDatePickerView: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.isHidden = true
        datePicker.maximumDate = Date()
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
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
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
        setupAccountAmountViewLayout()
        setupStartDateDisplayViewLayout()
        setupStartDatePickerViewLayout()
        setupEndDateDisplayViewLayout()
        setupEndDatePickerViewLayout()
        setupViewResultsButtonLayout()
    }
    
    private func setupAccountSelectionViewLayout() {
        addSubview(accountSelectionView)
        
        accountSelectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.leading.trailing.equalToSuperview()
        }
        
        accountSelectionView.separatorView.snp.updateConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupAccountAmountViewLayout() {
        addSubview(accountAmountView)
        
        accountAmountView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.algosAmountTopInset)
        }
    }
    
    private func setupStartDateDisplayViewLayout() {
        addSubview(startDateDisplayView)
        
        startDateDisplayView.snp.makeConstraints { make in
            make.top.equalTo(accountSelectionView.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        startDateDisplayView.separatorView.snp.updateConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
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
    
    private func setupEndDateDisplayViewLayout() {
        addSubview(endDateDisplayView)
        
        endDateDisplayView.snp.makeConstraints { make in
            make.top.equalTo(startDatePickerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        endDateDisplayView.separatorView.snp.updateConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
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
        startDate = picker.date
        endDatePickerView.minimumDate = startDate
        
        startDateDisplayView.detailLabel.text = startDate?.toFormat("dd MMMM yyyy")
    }
    
    @objc
    private func didChangeEndDate(picker: UIDatePicker) {
        endDate = picker.date
        startDatePickerView.maximumDate = endDate
        
        endDateDisplayView.detailLabel.text = endDate?.toFormat("dd MMMM yyyy")
    }
    
    @objc
    private func didTriggerStartDate(tapGestureRecognizer: UITapGestureRecognizer) {
        if startDatePickerView.isHidden {
            setStartDatePicker(visible: true)
        } else {
            setStartDatePicker(visible: false)
        }
    }
    
    @objc
    private func didTriggerEndDate(tapGestureRecognizer: UITapGestureRecognizer) {
        if endDatePickerView.isHidden {
            setEndDatePicker(visible: true)
        } else {
            setEndDatePicker(visible: false)
        }
    }
    
    // MARK: API
    
    private func setStartDatePicker(visible: Bool) {
        if visible {
            if !endDatePickerView.isHidden {
                endDateDisplayView.separatorView.isHidden = false
                endDatePickerView.isHidden = true
                
                endDatePickerView.snp.updateConstraints { make in
                    make.height.equalTo(0.0)
                }
                
                UIView.animate(withDuration: 0.3) {
                    self.layoutIfNeeded()
                }
            }
            
            startDateDisplayView.separatorView.isHidden = true
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
            
            startDateDisplayView.separatorView.isHidden = false
            
            UIView.animate(withDuration: 0.3) {
                self.startDatePickerView.isHidden = true
                
                self.layoutIfNeeded()
            }
        }
    }
    
    private func setEndDatePicker(visible: Bool) {
        if visible {
            if !startDatePickerView.isHidden {
                startDateDisplayView.separatorView.isHidden = false
                startDatePickerView.isHidden = true
                
                startDatePickerView.snp.updateConstraints { make in
                    make.height.equalTo(0.0)
                }
                
                UIView.animate(withDuration: 0.3) {
                    self.layoutIfNeeded()
                }
            }
            
            endDateDisplayView.separatorView.isHidden = true
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
            
            endDateDisplayView.separatorView.isHidden = false
            
            UIView.animate(withDuration: 0.3) {
                self.endDatePickerView.isHidden = true
                
                self.layoutIfNeeded()
            }
        }
    }
}
