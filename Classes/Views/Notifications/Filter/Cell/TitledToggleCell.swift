//
//  TitledToggleCell.swift

import UIKit

class TitledToggleCell: BaseCollectionViewCell<TitledToggleView> {

    weak var delegate: TitledToggleCellDelegate?

    override func linkInteractors() {
        super.linkInteractors()
        contextView.delegate = self
    }
}

extension TitledToggleCell {
    func bind(_ viewModel: TitledToggleViewModel) {
        contextView.bind(viewModel)
    }
}

extension TitledToggleCell: TitledToggleViewDelegate {
    func titledToggleView(_ titledToggleView: TitledToggleView, didChangeToggleValue value: Bool) {
        delegate?.titledToggleCell(self, didChangeToggleValue: value)
    }
}

protocol TitledToggleCellDelegate: class {
    func titledToggleCell(_ titledToggleCell: TitledToggleCell, didChangeToggleValue value: Bool)
}
