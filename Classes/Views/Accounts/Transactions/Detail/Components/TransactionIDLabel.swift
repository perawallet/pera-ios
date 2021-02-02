//
//  TransactionIDLabel.swift

import UIKit

class TransactionIDLabel: BaseView {
    
    weak var delegate: TransactionIDLabelDelegate?
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var titleLabel = TransactionDetailTitleLabel()
    
    private(set) lazy var copyImageView: UIImageView = {
        let imageView = UIImageView(image: img("icon-copy", isTemplate: true))
        imageView.tintColor = Colors.Component.transactionDetailCopyIcon
        return imageView
    }()
    
    private lazy var detailLabel: AlgoExplorerLabel = {
        let label = AlgoExplorerLabel()
        label.font = UIFont.font(withWeight: .medium(size: 14.0))
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        label.textColor = Colors.Text.primary
        return label
    }()
    
    private lazy var separatorView = LineSeparatorView()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.tertiary
        titleLabel.text = "transaction-detail-id".localized
    }
    
    override func linkInteractors() {
        detailLabel.delegate = self
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupCopyImageViewLayout()
        setupDetailLabelLayout()
        setupSeparatorViewLayout()
    }
}

extension TransactionIDLabel {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.verticalInset)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupCopyImageViewLayout() {
        addSubview(copyImageView)
        
        copyImageView.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(layout.current.copyImageOffset)
            make.centerY.equalTo(titleLabel)
            make.size.equalTo(layout.current.copyImageSize)
        }
    }
    
    private func setupDetailLabelLayout() {
        addSubview(detailLabel)
        
        detailLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(layout.current.verticalInset)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.labelTopOffset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
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

extension TransactionIDLabel {
    func setDetail(_ detail: String) {
        detailLabel.text = detail
    }
    
    func setSeparatorView(hidden: Bool) {
        separatorView.isHidden = hidden
    }
}

extension TransactionIDLabel: AlgoExplorerLabelDelegate {
    func algoExplorerLabelDidOpenExplorer(_ algoExplorerLabel: AlgoExplorerLabel) {
        delegate?.transactionIDLabelDidOpenExplorer(self)
    }
}

extension TransactionIDLabel {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let verticalInset: CGFloat = 20.0
        let separatorHeight: CGFloat = 1.0
        let labelTopOffset: CGFloat = 8.0
        let copyImageOffset: CGFloat = 8.0
        let copyImageSize = CGSize(width: 20.0, height: 20.0)
    }
}

protocol TransactionIDLabelDelegate: class {
    func transactionIDLabelDidOpenExplorer(_ transactionIDLabel: TransactionIDLabel)
}
