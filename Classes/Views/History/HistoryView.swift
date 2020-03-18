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
    func historyViewDidTapAssetSelectionView(_ historyView: HistoryView)
    func historyView(_ historyView: HistoryView, hasError message: String)
}

class HistoryView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: HistoryViewDelegate?
    
    var startDate = Date().dateByAdding(-1, .weekOfYear).date
    var endDate = Date()
    
    private(set) lazy var accountSelectionView: SelectionView = {
        let accountSelectionView = SelectionView(hasLeftImageView: true)
        accountSelectionView.backgroundColor = .clear
        accountSelectionView.leftExplanationLabel.text = "history-account".localized
        return accountSelectionView
    }()
    
    private(set) lazy var assetSelectionView: SelectionView = {
        let assetSelectionView = SelectionView()
        assetSelectionView.backgroundColor = .clear
        assetSelectionView.leftExplanationLabel.text = "history-asset".localized
        assetSelectionView.detailLabel.text = "send-select-asset".localized
        return assetSelectionView
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
    
    private lazy var rewardsSwitchView: RewardsSwitchView = {
        let view = RewardsSwitchView()
        view.isHidden = true
        return view
    }()

    private(set) lazy var viewResultsButton = MainButton(title: "title-view-results".localized)

    private lazy var accountSelectionGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(notifyDelegateToAccountSelectionViewTapped)
    )
    
    private lazy var assetSelectionGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(notifyDelegateToAssetSelectionViewTapped)
    )
    
    private lazy var startDateTapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(didTriggerStartDate(tapGestureRecognizer:))
    )
    
    private lazy var endDateTapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(didTriggerEndDate(tapGestureRecognizer:))
    )
    
    override func linkInteractors() {
        viewResultsButton.addTarget(self, action: #selector(notifyDelegateToViewResultsButtonTapped), for: .touchUpInside)
        accountSelectionView.addGestureRecognizer(accountSelectionGestureRecognizer)
        assetSelectionView.addGestureRecognizer(assetSelectionGestureRecognizer)
        startDateDisplayView.addGestureRecognizer(startDateTapGestureRecognizer)
        endDateDisplayView.addGestureRecognizer(endDateTapGestureRecognizer)
        startDatePickerView.addTarget(self, action: #selector(didChangeStartDate(picker:)), for: .valueChanged)
        endDatePickerView.addTarget(self, action: #selector(didChangeEndDate(picker:)), for: .valueChanged)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        setSelectionView(assetSelectionView, enabled: false)
    }
    
    override func prepareLayout() {
        setupAccountSelectionViewLayout()
        setupAssetSelectionViewLayout()
        setupStartDateDisplayViewLayout()
        setupEndDateDisplayViewLayout()
        setupStartDatePickerViewLayout()
        setupEndDatePickerViewLayout()
        setupViewResultsButtonLayout()
    }
}

extension HistoryView {
    private func setupAccountSelectionViewLayout() {
        addSubview(accountSelectionView)
        
        accountSelectionView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
        }
    }
    
    private func setupAssetSelectionViewLayout() {
        addSubview(assetSelectionView)
        
        assetSelectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(accountSelectionView.snp.bottom)
        }
    }
    
    private func setupStartDateDisplayViewLayout() {
        addSubview(startDateDisplayView)
        
        startDateDisplayView.snp.makeConstraints { make in
            make.top.equalTo(assetSelectionView.snp.bottom)
            make.leading.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width / 2)
        }
    }

    private func setupEndDateDisplayViewLayout() {
        addSubview(endDateDisplayView)
        
        endDateDisplayView.snp.makeConstraints { make in
            make.top.equalTo(assetSelectionView.snp.bottom)
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
    
    private func setupRewardsSwitchViewLayout() {
        addSubview(rewardsSwitchView)
        
        rewardsSwitchView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.rewardsViewInset)
            make.top.equalTo(startDatePickerView.snp.bottom).offset(layout.current.rewardsViewInset)
        }
    }
    
    private func setupViewResultsButtonLayout() {
        addSubview(viewResultsButton)
        
        viewResultsButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(endDatePickerView.snp.bottom)
                .offset(layout.current.buttonMinimumInset)
            make.top.greaterThanOrEqualTo(startDatePickerView.snp.bottom)
                .offset(layout.current.buttonMinimumInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
            make.bottom.equalToSuperview().inset(safeAreaBottom + layout.current.bottomInset)
        }
    }
}

extension HistoryView {
    @objc
    private func notifyDelegateToViewResultsButtonTapped() {
        delegate?.historyViewDidTapViewResultsButton(self)
    }
    
    @objc
    private func notifyDelegateToAccountSelectionViewTapped() {
        delegate?.historyViewDidTapAccountSelectionView(self)
    }
    
    @objc
    private func notifyDelegateToAssetSelectionViewTapped() {
        delegate?.historyViewDidTapAssetSelectionView(self)
    }
}

extension HistoryView {
    @objc
    private func didChangeStartDate(picker: UIDatePicker) {
        if picker.date > Date() {
            delegate?.historyView(self, hasError: "history-future-date-error".localized)
            startDatePickerView.date = startDate
            return
        } else if picker.date > endDate {
            delegate?.historyView(self, hasError: "history-end-date-error".localized)
            startDatePickerView.date = startDate
            return
        }
        
        startDate = picker.date
        
        startDateDisplayView.detailLabel.text = startDate.toFormat("dd MMMM yyyy")
    }
    
    @objc
    private func didChangeEndDate(picker: UIDatePicker) {
        if picker.date > Date() {
            delegate?.historyView(self, hasError: "history-future-date-error".localized)
            endDatePickerView.date = endDate
            return
        }
        
        if startDate > picker.date {
            delegate?.historyView(self, hasError: "history-end-date-error".localized)
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
}

extension HistoryView {
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
                
                self.startDateDisplayView.alpha = 1.0
                self.endDateDisplayView.alpha = 0.3
            }
        } else {
            startDatePickerView.snp.updateConstraints { make in
                make.height.equalTo(0.0)
            }
            
            UIView.animate(withDuration: 0.3) {
                self.startDatePickerView.isHidden = true
                
                self.layoutIfNeeded()
                
                self.startDateDisplayView.alpha = 1.0
                self.endDateDisplayView.alpha = 1.0
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
                
                self.startDateDisplayView.alpha = 0.3
                self.endDateDisplayView.alpha = 1.0
            }
            
        } else {
            endDatePickerView.snp.updateConstraints { make in
                make.height.equalTo(0.0)
            }
            
            UIView.animate(withDuration: 0.3) {
                self.endDatePickerView.isHidden = true
                
                self.layoutIfNeeded()
                
                self.startDateDisplayView.alpha = 1.0
                self.endDateDisplayView.alpha = 1.0
            }
        }
    }
}

extension HistoryView {
    func setSelectionView(_ selectionView: SelectionView, enabled: Bool) {
        selectionView.set(enabled: enabled)
    }
}

extension HistoryView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let bottomInset: CGFloat = 75.0
        let buttonMinimumInset: CGFloat = -5.0
        let buttonHorizontalInset: CGFloat = MainButton.Constants.horizontalInset
        let rewardsViewInset: CGFloat = 15.0
        let arrowTopInset: CGFloat = 19.0
    }
}

extension HistoryView {
    private enum Colors {
        static let disabledColor = rgb(0.91, 0.91, 0.92)
    }
}
