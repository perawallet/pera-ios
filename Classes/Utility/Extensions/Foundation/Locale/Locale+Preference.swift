//
//  Locale+Preference.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 12.10.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

extension Locale {
    static func preferred() -> Locale {
        guard let preferredLanguageIdentifier = Bundle.main.preferredLocalizations.first else {
            return Locale.current
        }
        return Locale(identifier: preferredLanguageIdentifier)
    }
}
