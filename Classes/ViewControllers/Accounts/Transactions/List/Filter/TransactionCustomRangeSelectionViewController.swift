//
//  TransactionCustomRangeSelectionViewController.swift

import UIKit
import SwiftDate

class TransactionCustomRangeSelectionViewController: BaseViewController {
    
    weak var delegate: TransactionCustomRangeSelectionViewControllerDelegate?
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var transactionCustomRangeSelectionView = TransactionCustomRangeSelectionView()
    
    private var isFromRangeSelectionSelected = true
    private var fromDate: Date
    private var toDate: Date
    
    init(fromDate: Date?, toDate: Date?, configuration: ViewControllerConfiguration) {
        self.fromDate = fromDate ?? Date().dateAt(.yesterday)
        self.toDate = toDate ?? Date()
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        let doneBarButtonItem = ALGBarButtonItem(kind: .done) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.delegate?.transactionCustomRangeSelectionViewController(
                strongSelf,
                didSelect: (from: strongSelf.fromDate, to: strongSelf.toDate)
            )
            strongSelf.dismissScreen()
        }
        
        rightBarButtonItems = [doneBarButtonItem]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setIntiailModalSize()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateToOldModalSize()
    }
    
    override func configureAppearance() {
        view.backgroundColor = Colors.Background.secondary
        setSecondaryBackgroundColor()
        title = "transaction-filter-option-custom".localized
        transactionCustomRangeSelectionView.setFromDate(fromDate.toFormat("dd.MM.yyyy"))
        transactionCustomRangeSelectionView.setToDate(toDate.toFormat("dd.MM.yyyy"))
        transactionCustomRangeSelectionView.setPickerDate(fromDate)
    }
    
    override func setListeners() {
        handleFromRangeSelectionActions()
        handleToRangeSelectionActions()
        handleDatePickerChangeActions()
    }
    
    override func prepareLayout() {
        setupTransactionCustomRangeSelectionViewLayout()
    }
}

extension TransactionCustomRangeSelectionViewController {
    private func setIntiailModalSize() {
        modalPresenter?.changeModalSize(to: .custom(layout.current.modalSize), animated: false)
        view.layoutIfNeeded()
    }
    
    private func updateToOldModalSize() {
        modalPresenter?.changeModalSize(to: .custom(layout.current.oldModalSize), animated: false)
        view.layoutIfNeeded()
    }
    
    private func setupTransactionCustomRangeSelectionViewLayout() {
        view.addSubview(transactionCustomRangeSelectionView)
        
        transactionCustomRangeSelectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension TransactionCustomRangeSelectionViewController {
    private func handleFromRangeSelectionActions() {
        transactionCustomRangeSelectionView.fromRangeSelectionHandler = { [weak self] fromRangeSelectionView -> Void in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.isFromRangeSelectionSelected = true
            strongSelf.transactionCustomRangeSelectionView.setFromRangeSelectionViewSelected(true)
            strongSelf.transactionCustomRangeSelectionView.setToRangeSelectionViewSelected(false)
            strongSelf.transactionCustomRangeSelectionView.setPickerDate(strongSelf.fromDate)
        }
    }
    
    private func handleToRangeSelectionActions() {
        transactionCustomRangeSelectionView.toRangeSelectionHandler = { [weak self] toRangeSelectionView -> Void in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.isFromRangeSelectionSelected = false
            strongSelf.transactionCustomRangeSelectionView.setFromRangeSelectionViewSelected(false)
            strongSelf.transactionCustomRangeSelectionView.setToRangeSelectionViewSelected(true)
            strongSelf.transactionCustomRangeSelectionView.setPickerDate(strongSelf.toDate)
        }
    }
    
    private func handleDatePickerChangeActions() {
        transactionCustomRangeSelectionView.datePickerChangesHandler = { [weak self] datePickerView -> Void in
            guard let strongSelf = self else {
                return
            }
            
            if strongSelf.isFromRangeSelectionSelected {
                if datePickerView.date > strongSelf.toDate {
                    datePickerView.date = strongSelf.fromDate
                    return
                }
                
                strongSelf.fromDate = datePickerView.date
                strongSelf.transactionCustomRangeSelectionView.setFromDate(strongSelf.fromDate.toFormat("dd.MM.yyyy"))
            } else {
                if datePickerView.date < strongSelf.fromDate {
                    datePickerView.date = strongSelf.toDate
                    return
                }
                
                strongSelf.toDate = datePickerView.date
                strongSelf.transactionCustomRangeSelectionView.setToDate(strongSelf.toDate.toFormat("dd.MM.yyyy"))
            }
        }
    }
}

extension TransactionCustomRangeSelectionViewController {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let modalSize = CGSize(width: UIScreen.main.bounds.width, height: 416.0)
        let oldModalSize = CGSize(width: UIScreen.main.bounds.width, height: 506.0)
    }
}

protocol TransactionCustomRangeSelectionViewControllerDelegate: class {
    func transactionCustomRangeSelectionViewController(
        _ transactionCustomRangeSelectionViewController: TransactionCustomRangeSelectionViewController,
        didSelect range: (from: Date, to: Date)
    )
}
