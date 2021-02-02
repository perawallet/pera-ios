//
//  ModalPresenterInteractable.swift

import Foundation

protocol ModalPresenterInteractable {
    func changeModalSize(to newModalSize: ModalSize, animated: Bool)
    func changeModalSize(to newModalSize: ModalSize, animated: Bool, then completion: (() -> Void)?)
}
