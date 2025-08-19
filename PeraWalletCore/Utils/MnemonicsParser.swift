// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   MnemonicsParser.swift

import Foundation

public final class MnemonicsParser {
    public let separators: CharacterSet
    public let wordCount: Int

    public init(wordCount: Int) {
        var separators = CharacterSet()
        separators.formUnion(.whitespacesAndNewlines)
        separators.formUnion(.punctuationCharacters)
        separators.formUnion(.symbols)
        self.separators = separators
        self.wordCount = wordCount
    }
}

extension MnemonicsParser {
    public func parse(
        _ text: String
    ) throws -> Mnemonics {
        var words = text.components(separatedBy: separators)
        /// <note>
        /// There is an extension method in 'Macaroon' which has the same signature with the
        /// built-in one.
        /// <todo>
        /// The signature of the one in 'Macaroon' may change.
        words.removeAll(where: \.isEmpty) as Void

        guard let mnemonics = Mnemonics(words, wordLimit: wordCount) else {
            throw MnemonicsError.missingWords
        }

        return mnemonics
    }
}

public enum Mnemonics {
    case zero
    case one(Word)
    case full([Word])

    init?(
        _ words: [Word],
        wordLimit: Int
    ) {
        switch words.count {
        case 0: self = .zero
        case 1: self = .one(words[0])
        case wordLimit: self = .full(words)
        default: return nil
        }
    }
}

extension Mnemonics {
    public typealias Word = String
}

public enum MnemonicsError: Error {
    case missingWords
}
