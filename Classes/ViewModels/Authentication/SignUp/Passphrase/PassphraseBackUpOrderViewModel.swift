//
//  PassphraseBackUpOrderViewModel.swift

import Foundation

class PassphraseBackUpOrderViewModel {
    private(set) var number: String?
    private(set) var phrase: String?

    init(mnemonics: [String]?, index: Int) {
        setNumber(from: index)
        setPhrase(from: mnemonics, at: index)
    }

    private func setNumber(from index: Int) {
        number = "\(index + 1)"
    }

    private func setPhrase(from mnemonics: [String]?, at index: Int) {
        if let mnemonics = mnemonics {
            phrase = mnemonics[index]
        }
    }
}
