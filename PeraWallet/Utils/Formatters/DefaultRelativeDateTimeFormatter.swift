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

//   DefaultRelativeDateTimeFormatter.swift

import Foundation

final class DefaultRelativeDateTimeFormatter: RelativeDateTimeFormatter {

    enum AdditionalTextOption {
        case `default`
        case none
        case custom(prefix: String, suffix: String)
    }
    
    // MARK: - Properties
    
    private let isNagativeValuesAllowed: Bool
    private let additionalTextOption: AdditionalTextOption
    
    private let exludedWords: Set<String> = ["in", "ago"]
    
    // MARK: - Initialisers
    
    init(unitsStyle: UnitsStyle, isNagativeValuesAllowed: Bool, additionalTextOption: AdditionalTextOption) {
        self.isNagativeValuesAllowed = isNagativeValuesAllowed
        self.additionalTextOption = additionalTextOption
        super.init()
        self.unitsStyle = unitsStyle
        locale = Locale(languageCode: .english)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Formatter
    
    func string(date: Date) -> String {
        
        let adjustedDate = adjustedDate(date: date)
        
        switch additionalTextOption {
        case .default:
            return super.localizedString(fromTimeInterval: adjustedDate.timeIntervalSinceNow)
        case .none:
            return rawTime(date: adjustedDate)
        case let .custom(prefix, suffix):
            return [prefix, rawTime(date: adjustedDate), suffix].joined(separator: " ")
        }
    }
    
    // MARK: - Helpers
    
    private func adjustedDate(date: Date) -> Date {
        guard !isNagativeValuesAllowed else { return date }
        return max(date, Date())
    }
    
    private func rawTime(date: Date) -> String {
        super.localizedString(fromTimeInterval: date.timeIntervalSinceNow)
            .split(separator: " ")
            .map { String($0) }
            .filter { !exludedWords.contains($0) }
            .joined(separator: " ")
    }
}
