//
//  UITextView+Additions.swift

import UIKit

extension UITextView {
    func bindHtml(_ html: String?, with attributes: [NSAttributedString.Key: Any] ) {
        guard let data = html?.data(using: .unicode),
            let attributedString = try? NSMutableAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil) else {
                return
        }
        
        attributedString.addAttributes(attributes, range: NSRange(location: 0, length: attributedString.string.count))
        self.attributedText = attributedString
    }
}
