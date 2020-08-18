//
//  NotificationBanner.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 13.08.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation
import NotificationBannerSwift

enum NotificationBanner {
    static func showInformation(_ information: String, completion handler: EmptyHandler? = nil) {
        let banner = FloatingNotificationBanner(
            title: information,
            titleFont: UIFont.font(withWeight: .semiBold(size: 16.0)),
            titleColor: SharedColors.primaryText,
            titleTextAlign: .left,
            colors: CustomBannerColors()
        )
        
        banner.duration = 3.0
        
        banner.show(
            edgeInsets: UIEdgeInsets(top: 20.0, left: 20.0, bottom: 0.0, right: 20.0),
            cornerRadius: 10.0,
            shadowColor: rgba(0.0, 0.0, 0.0, 0.1),
            shadowOpacity: 1.0,
            shadowBlurRadius: 6.0,
            shadowCornerRadius: 6.0,
            shadowOffset: UIOffset(horizontal: 0.0, vertical: 2.0)
        )
        
        banner.onTap = handler
    }
    
    static func showError(_ error: String, message: String) {
        let banner = FloatingNotificationBanner(
            title: error,
            subtitle: message,
            titleFont: UIFont.font(withWeight: .semiBold(size: 16.0)),
            titleColor: SharedColors.white,
            titleTextAlign: .left,
            subtitleFont: UIFont.font(withWeight: .regular(size: 14.0)),
            subtitleColor: SharedColors.white,
            subtitleTextAlign: .left,
            leftView: UIImageView(image: img("icon-warning-circle")),
            style: .warning,
            colors: CustomBannerColors()
        )
        
        banner.duration = 3.0
        
        banner.show(
            edgeInsets: UIEdgeInsets(top: 20.0, left: 20.0, bottom: 0.0, right: 20.0),
            cornerRadius: 12.0,
            shadowColor: SharedColors.errorShadow,
            shadowOpacity: 1.0,
            shadowBlurRadius: 20.0,
            shadowCornerRadius: 6.0,
            shadowOffset: UIOffset(horizontal: 0.0, vertical: 12.0)
        )
    }
    
    static func showSuccess(_ success: String, message: String) {
        let banner = FloatingNotificationBanner(
            title: success,
            subtitle: message,
            titleFont: UIFont.font(withWeight: .semiBold(size: 16.0)),
            titleColor: SharedColors.white,
            titleTextAlign: .left,
            subtitleFont: UIFont.font(withWeight: .regular(size: 14.0)),
            subtitleColor: SharedColors.white,
            subtitleTextAlign: .left,
            style: .success,
            colors: CustomBannerColors()
        )
        
        banner.duration = 3.0
        banner.show(edgeInsets: UIEdgeInsets(top: 20.0, left: 20.0, bottom: 0.0, right: 20.0), cornerRadius: 12.0)
    }
}

class CustomBannerColors: BannerColorsProtocol {
    internal func color(for style: BannerStyle) -> UIColor {
        switch style {
        case .warning:
            return SharedColors.red
        case .success:
            return SharedColors.primary
        default:
            return SharedColors.white
        }
    }
}
