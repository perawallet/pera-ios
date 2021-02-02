//
//  Locale+Preference.swift

import Foundation

extension Locale {
    static func preferred() -> Locale {
        guard let preferredLanguageIdentifier = Bundle.main.preferredLocalizations.first else {
            return Locale.current
        }
        return Locale(identifier: preferredLanguageIdentifier)
    }
}
