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
//  NotificationView.swift

import UIKit
import MacaroonUIKit

final class NotificationView: View {
    private lazy var theme = NotificationViewTheme()
    
    private lazy var badgeImageView = UIImageView()
    private lazy var notificationImageView = UIImageView()
    private lazy var titleLabel = UILabel()
    private lazy var timeLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(theme)
    }

    func customize(_ theme: NotificationViewTheme) {
        addBadgeImageView(theme)
        addNotificationImageView(theme)
        addTitleLabel(theme)
        addTimeLabel(theme)
    }

    func prepareLayout(_ layoutSheet: NotificationViewTheme) {}

    func customizeAppearance(_ styleSheet: NotificationViewTheme) {}
}

extension NotificationView {
    private func addBadgeImageView(_ theme: NotificationViewTheme) {
        badgeImageView.customizeAppearance(theme.badgeImage)

        addSubview(badgeImageView)
        badgeImageView.snp.makeConstraints {
            $0.fitToSize(theme.badgeImageSize)
            $0.top.equalToSuperview().inset(theme.badgeImageTopPadding)
            $0.leading.equalToSuperview().inset(theme.badgeImageHorizontalPaddings.leading)
        }

        badgeImageView.isHidden = true
    }
    
    private func addNotificationImageView(_ theme: NotificationViewTheme) {
        notificationImageView.layer.cornerRadius = theme.notificationImageSize.h / 2
        notificationImageView.clipsToBounds = true
        notificationImageView.contentMode = .center

        addSubview(notificationImageView)
        notificationImageView.snp.makeConstraints {
            $0.fitToSize(theme.notificationImageSize)
            $0.top.equalToSuperview().inset(theme.notificationImageTopPadding)
            $0.leading.equalTo(badgeImageView.snp.trailing).offset(theme.badgeImageHorizontalPaddings.trailing)
        }
    }
    
    private func addTitleLabel(_ theme: NotificationViewTheme) {
        titleLabel.customizeAppearance(theme.titleLabel)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(notificationImageView)
            $0.leading.equalTo(notificationImageView.snp.trailing).offset(theme.titleLabelLeadingPadding)
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }
    
    private func addTimeLabel(_ theme: NotificationViewTheme) {
        timeLabel.customizeAppearance(theme.timeLabel)

        addSubview(timeLabel)
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.timeLabelVerticalPaddings.top)
            $0.bottom.equalToSuperview().inset(theme.timeLabelVerticalPaddings.bottom)
            $0.leading.equalTo(titleLabel)
        }
    }
}

extension NotificationView {
    func reset() {
        badgeImageView.isHidden = true
        notificationImageView.image = nil
        titleLabel.attributedText = nil
        timeLabel.text = nil
    }
}

extension NotificationView: ViewModelBindable {
    func bindData(_ viewModel: NotificationsViewModel?) {
        badgeImageView.isHidden = viewModel?.isRead ?? true
        notificationImageView.image = viewModel?.notificationImage
        titleLabel.attributedText = viewModel?.title
        timeLabel.text = viewModel?.time
    }
}

extension NotificationView {
    static func calculatePreferredSize(_ viewModel: NotificationsViewModel?, with theme: NotificationViewTheme) -> CGSize {
        guard let viewModel = viewModel else {
            return .zero
        }

        let width = UIScreen.main.bounds.width
        let constantHeight =
        theme.timeLabelVerticalPaddings.top +
        theme.timeLabelVerticalPaddings.bottom +
        theme.notificationImageTopPadding

        let titleLabelHeight = viewModel.title?.string.height(
            withConstrained: width - (
                theme.badgeImageSize.w +
                (theme.badgeImageHorizontalPaddings.leading + theme.badgeImageHorizontalPaddings.trailing) +
                theme.notificationImageSize.w +
                theme.titleLabelLeadingPadding +
                theme.horizontalPadding
            ),
            font: Fonts.DMSans.regular.make(15).font
        ) ?? 40
        let timeLabelHeight: CGFloat = 17
        let height: CGFloat = constantHeight + titleLabelHeight + timeLabelHeight
        return CGSize(width: width, height: height)
    }
}
