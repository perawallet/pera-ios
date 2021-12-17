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
//   EditNoteView.swift


import Foundation
import UIKit
import MacaroonUIKit

final class EditNoteView: View {
    weak var delegate: EditNoteViewDelegate?

    private(set) lazy var noteInputView = createNoteTextInput(
        placeholder: "edit-note-note-explanation".localized,
        floatingPlaceholder: "edit-note-note-explanation".localized
    )

    private lazy var doneButton = Button()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setListeners()
        linkInteractors()
    }

    func customize(_ theme: EditNoteViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addNoteInputView(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func linkInteractors() {
        noteInputView.editingDelegate = self
        noteInputView.delegate = self
    }
}

extension EditNoteView {
    private func addNoteInputView(_ theme: EditNoteViewTheme) {
        addSubview(noteInputView)
        noteInputView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.equalToSuperview().offset(theme.verticalPadding)
        }
    }
}

extension EditNoteView {
    func createNoteTextInput(
        placeholder: String,
        floatingPlaceholder: String?
    ) -> FloatingTextInputFieldView {
        let view = FloatingTextInputFieldView()
        let textInputBaseStyle: TextInputStyle = [
            .font(Fonts.DMSans.regular.make(15, .body)),
            .tintColor(AppColors.Components.Text.main),
            .textColor(AppColors.Components.Text.main),
            .clearButtonMode(.whileEditing),
            .returnKeyType(.done),
            .autocapitalizationType(.words),
            .textContentType(.name)
        ]

        let theme =
            FloatingTextInputFieldViewCommonTheme(
                textInput: textInputBaseStyle,
                placeholder: placeholder,
                floatingPlaceholder: floatingPlaceholder
            )
        view.customize(theme)
        view.snp.makeConstraints {
            $0.greaterThanHeight(48)
        }
        return view
    }
}

extension EditNoteView {
    func bindData(_ note: String?) {
        noteInputView.text = note
    }
}

extension EditNoteView {
    func beginEditing() {
        noteInputView.beginEditing()
    }
}

extension EditNoteView: FloatingTextInputFieldViewDelegate {
    func floatingTextInputFieldViewShouldReturn(_ view: FloatingTextInputFieldView) -> Bool {
        view.endEditing()
        return true
    }
}

extension EditNoteView: FormInputFieldViewEditingDelegate {
    func formInputFieldViewDidBeginEditing(_ view: FloatingTextInputFieldView) {
        delegate?.editNoteViewDidChangeValue(self)
    }

    func formInputFieldViewDidEdit(_ view: FloatingTextInputFieldView) {
        delegate?.editNoteViewDidChangeValue(self)
    }

    func formInputFieldViewDidEndEditing(_ view: FloatingTextInputFieldView) {
        delegate?.editNoteViewDidChangeValue(self)
    }
}

protocol EditNoteViewDelegate: AnyObject {
    func editNoteViewDidChangeValue(_ editNoteView: EditNoteView)
}
