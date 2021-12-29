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
//  ContactDisplayView.swift

import UIKit
import MacaroonUIKit

final class ContactDisplayView: View {
    weak var delegate: ContactDisplayViewDelegate?

    private lazy var horizontalStackView = UIStackView()
    private lazy var imageView = UIImageView()
    private lazy var nameLabel = UILabel()
    private lazy var addContactButton = UIButton()

    func setListeners() {
        addContactButton.addTarget(self, action: #selector(notifyDelegateToHandleAddContact), for: .touchUpInside)
    }

    func customize(_ theme: ContactDisplayViewTheme) {
        addImageView(theme)
        addNameLabel(theme)
        addAddContactButton(theme)
    }
    
    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: ViewStyle) {}
}

extension ContactDisplayView {
    @objc
    private func notifyDelegateToHandleAddContact() {
        delegate?.contactDisplayViewDidTapAddContactButton(self)
    }
}

extension ContactDisplayView {
    private func addImageView(_ theme: ContactDisplayViewTheme) {
        imageView.customizeAppearance(theme.contactImage)
        imageView.layer.cornerRadius = theme.contactImageCorner.radius
        imageView.layer.masksToBounds = true

        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.fitToSize(theme.contactImageSize)
        }
    }

    private func addNameLabel(_ theme: ContactDisplayViewTheme) {
        nameLabel.customizeAppearance(theme.nameLabel)

        addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().priority(.low)
            $0.top.bottom.equalToSuperview()
            $0.leading.equalTo(imageView.snp.trailing).offset(theme.horizontalPadding)
            $0.leading.equalToSuperview().priority(.high)
        }
    }

    private func addAddContactButton(_ theme: ContactDisplayViewTheme) {
        addContactButton.customizeAppearance(theme.addContactButton)

        addSubview(addContactButton)
        addContactButton.snp.makeConstraints {
            $0.leading.equalTo(nameLabel.snp.trailing).offset(theme.horizontalPadding)
            $0.fitToSize(theme.addContactButtonSize)
            $0.top.trailing.equalToSuperview()
        }

        addContactButton.layer.cornerRadius = theme.addContactButtonCorner.radius
        addContactButton.layer.masksToBounds = true
    }
}

extension ContactDisplayView {
    func setContact(_ contact: Contact) {
        removeAddContactButton()

        if let imageData = contact.image,
            let image = UIImage(data: imageData) {
            let resizedImage = image.convert(to: CGSize(width: 24, height: 24))
            imageView.image = resizedImage
        } else {
            removeContactImage()
        }
        
        nameLabel.text = contact.name
    }
    
    func removeAddContactButton() {
        nameLabel.font = Fonts.DMSans.regular.make(15).uiFont
        addContactButton.removeFromSuperview()
    }
    
    func setName(_ name: String) {
        nameLabel.text = name
        removeContactImage()
    }
    
    func removeContactImage() {
        imageView.removeFromSuperview()
    }
}

protocol ContactDisplayViewDelegate: AnyObject {
    func contactDisplayViewDidTapAddContactButton(_ contactDisplayView: ContactDisplayView)
}
