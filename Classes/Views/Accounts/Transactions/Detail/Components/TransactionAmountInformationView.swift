//
//  TransactionAmountInformationView.swift

import UIKit

class TransactionAmountInformationView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var titleLabel = TransactionDetailTitleLabel()
    
    private lazy var transactionAmountView = TransactionAmountView()
    
    private lazy var separatorView = LineSeparatorView()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.tertiary
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupTransactionAmountViewLayout()
        setupSeparatorViewLayout()
    }
}

extension TransactionAmountInformationView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.labelTopInset)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupTransactionAmountViewLayout() {
        addSubview(transactionAmountView)
        
        transactionAmountView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(layout.current.transactionAmountViewOffset)
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(layout.current.transactionAmountViewOffset)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension TransactionAmountInformationView {
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setAmountViewMode(_ mode: TransactionAmountView.Mode) {
        transactionAmountView.mode = mode
    }
    
    func setSeparatorHidden(_ hidden: Bool) {
        separatorView.isHidden = hidden
    }
}

extension TransactionAmountInformationView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let transactionAmountViewOffset: CGFloat = 20.0
        let labelTopInset: CGFloat = 20.0
        let separatorHeight: CGFloat = 1.0
    }
}
