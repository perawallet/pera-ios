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
    func historyView(_ historyView: HistoryView, didSelectStartDate date: Date)
    func historyView(_ historyView: HistoryView, didSelectEndDate date: Date)
}

class HistoryView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 15.0 * verticalScale
        let horizontalInset: CGFloat = 25.0
        let accountsViewInset: CGFloat = 20.0
        let bottomInset: CGFloat = 25.0
        let buttonMinimumInset: CGFloat = 18.0 * verticalScale
    }
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: HistoryViewDelegate?

    private(set) lazy var accountSelectionView: DetailedInformationView = {
        let accountView = DetailedInformationView()
        accountView.backgroundColor = .white
        accountView.explanationLabel.text = "send-algos-from".localized
        accountView.detailLabel.text = "send-algos-select".localized
        return accountView
    }()
    
    private(set) lazy var startDateDisplayView: DetailedInformationView = {
        let startDateDisplayView = DetailedInformationView()
        startDateDisplayView.backgroundColor = .white
        startDateDisplayView.explanationLabel.text = "send-algos-from".localized
        startDateDisplayView.detailLabel.text = "send-algos-select".localized
        return startDateDisplayView
    }()
    
    private(set) lazy var startDatePickerView: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.isHidden = true
        return datePicker
    }()
    
    private(set) lazy var endDateDisplayView: DetailedInformationView = {
        let endDateDisplayView = DetailedInformationView()
        endDateDisplayView.backgroundColor = .white
        endDateDisplayView.explanationLabel.text = "send-algos-from".localized
        endDateDisplayView.detailLabel.text = "send-algos-select".localized
        return endDateDisplayView
    }()
    
    private(set) lazy var endDatePickerView: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.isHidden = true
        return datePicker
    }()

    private(set) lazy var viewResultsButton = MainButton(title: "title-view-results".localized)
    
    // MARK: Gestures
    
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
    
//        datePickerView.addTarget(self,
//                                 action: #selector(didChange(datePicker:)),
//                                 for: .valueChanged)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupAccountSelectionViewLayout()
        setupStartDateDisplayViewLayout()
        setupStartDatePickerViewLayout()
        setupEndDateDisplayViewLayout()
        setupEndDatePickerViewLayout()
        setupViewResultsButtonLayout()
    }
    
    private func setupAccountSelectionViewLayout() {
        addSubview(accountSelectionView)
        
        accountSelectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5.0)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupStartDateDisplayViewLayout() {
        addSubview(startDateDisplayView)
        
        startDateDisplayView.snp.makeConstraints { make in
            make.top.equalTo(accountSelectionView.snp.bottom)
            make.leading.trailing.equalToSuperview()
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
            make.top.greaterThanOrEqualTo(endDatePickerView.snp.bottom).offset(60.0)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(layout.current.bottomInset)
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToViewResultsButtonTapped() {
        delegate?.historyViewDidTapViewResultsButton(self)
    }
    
    @objc func didTriggerStartDate(tapGestureRecognizer: UITapGestureRecognizer) {
        delegate?.historyView(self, didSelectStartDate: startDatePickerView.date)
    }
    
    @objc func didTriggerEndDate(tapGestureRecognizer: UITapGestureRecognizer) {
        delegate?.historyView(self, didSelectEndDate: endDatePickerView.date)
    }
}
