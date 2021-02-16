// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  PassPhraseViewModel.swift

import Foundation

class PassphraseViewModel {
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
        
        generateRandomIndexes()
        generateRandomMnemonics()
    }
}

extension PassphraseViewModel {
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

extension PassphraseViewModel {
    private func generateRandomIndexes() {
        while validationIndexes.count < numberOfValidations {
            let randomIndex = Int.random(in: 0 ..< mnemonics.count)
            
            if validationIndexes.contains(randomIndex) {
                continue
            }
            
            validationIndexes.append(randomIndex)
        }
    }
    
    private func generateRandomMnemonics() {
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
