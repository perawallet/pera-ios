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
//   AnnouncmentBannerView.swift

import MacaroonUIKit

final class AnnouncmentBannerView: View {
    private lazy var titleLabel = Label()
    private lazy var detailLabel = Label()
    private lazy var dismissButton = Button()
    private lazy var outerImageView = ImageView()
    private lazy var innerImageView = ImageView()

    func customize(_ theme: AnnouncmentBannerViewTheme) {
        addOuterImageView(theme)
        addInnerImageView(theme)
        addDismissButton(theme)
        addTitleLabel(theme)
        addDetailLabel(theme)
    }

    func customizeAppearance(_ styleSheet: StyleSheet) { }
    func prepareLayout(_ layoutSheet: LayoutSheet) { }
}

extension AnnouncmentBannerView {
    private func addOuterImageView(_ theme: AnnouncmentBannerViewTheme) {

    }

    private func addInnerImageView(_ theme: AnnouncmentBannerViewTheme) {

    }

    private func addDismissButton(_ theme: AnnouncmentBannerViewTheme) {

    }

    private func addTitleLabel(_ theme: AnnouncmentBannerViewTheme) {

    }

    private func addDetailLabel(_ theme: AnnouncmentBannerViewTheme) {

    }
}

extension AnnouncmentBannerView: ViewModelBindable {
    func bindData(_ viewModel: AnnouncmentBannerViewModel?) {

    }
}

final class AnnouncmentBannerCell: BaseCollectionViewCell<AnnouncmentBannerView> {

    override func configureAppearance() {
        super.configureAppearance()
        contextView.customize(AnnouncmentBannerViewTheme())
    }
}
