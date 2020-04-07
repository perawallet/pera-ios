//
//  PassPhraseViewModel.swift
//  algorand
//
//  Created by Omer Emre Aslan on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

class PassPhraseViewModel {
    private let privateKey: Data
    
    fileprivate let numberOfShownMnemonic = 18 // It should be less than 25
    let numberOfValidations = 3
    fileprivate(set) var currentIndex = 0
    
    private(set) var validationIndexes: [Int] = []
    
    private let mnemonics: [String]
    fileprivate var shownMnemonics: [String] = []
    
    required init(privateKey: Data) {
        self.privateKey = privateKey
        
        var error: NSError?
        let mnemonics = AlgorandSDK().mnemonicFrom(privateKey, error: &error)
        
        guard error == nil else {
            self.mnemonics = []
            return
        }
        
        self.mnemonics = mnemonics.components(separatedBy: " ")
        
        self.generateRandomIndexes()
        self.generateRandomMnemonics()
    }
}

// MARK: - API
extension PassPhraseViewModel {
    func getMnemonics() -> [String] {
        return shownMnemonics
    }
    
    func numberOfMnemonic() -> Int {
        return shownMnemonics.count
    }
    
    func mnemonic(atIndex index: Int) -> String? {
        guard index < shownMnemonics.count else {
            return nil
        }
        
        return shownMnemonics[index]
    }
    
    func checkMnemonic(_ mnemonic: String) -> Bool {
        guard currentIndex < validationIndexes.count else {
            return false
        }
        
        let index = validationIndexes[currentIndex]
        
        return self.mnemonics[index] == mnemonic
    }
    
    func incrementCurrentIndex() {
        guard currentIndex < numberOfValidations - 1 else {
            return
        }
        
        currentIndex = currentIndex.advanced(by: 1)
    }
    
    func currentIndexValue() -> Int {
        guard currentIndex < validationIndexes.count else {
            return 0
        }
        
        return validationIndexes[currentIndex]
    }
}

// MARK: - Helpers
extension PassPhraseViewModel {
    fileprivate func generateRandomIndexes() {
        
        while validationIndexes.count < numberOfValidations {
            let randomIndex = Int.random(in: 0 ..< mnemonics.count)
            
            if validationIndexes.contains(randomIndex) {
                continue
            }
            
            validationIndexes.append(randomIndex)
        }
    }
    
    fileprivate func generateRandomMnemonics() {
        var randomMnemonics: Set<String> = []
        
        for index in validationIndexes {
            randomMnemonics.insert(mnemonics[index])
        }
        
        let shuffledMnemonics = mnemonics.shuffled()
        
        for mnemonic in shuffledMnemonics {
            if randomMnemonics.count == numberOfShownMnemonic {
                break
            }
            
            if randomMnemonics.contains(mnemonic) {
                continue
            }
            
            randomMnemonics.insert(mnemonic)
        }
        
        let sortedMnemonics = randomMnemonics.sorted { $0 < $1 }
        self.shownMnemonics = sortedMnemonics
    }
}
