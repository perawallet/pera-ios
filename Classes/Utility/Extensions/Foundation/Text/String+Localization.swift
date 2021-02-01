//
//  String+Localization.swift

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(params: CVarArg...) -> String {
        return String(format: NSLocalizedString(self, comment: ""), arguments: params)
    }
}
