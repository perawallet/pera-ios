// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   RecoverAccountsLoadingTheme.swift

import MacaroonUIKit
import UIKit

extension RecoverAccountsLoadingScreen {
    struct Theme:
        StyleSheet,
        LayoutSheet {
        let background: ViewStyle
        let imageBackground: ViewStyle
        let leftImage: ImageStyle
        let leftImageSize: LayoutSize
        let imageSize: LayoutSize
        let rightImage: ImageStyle
        let rightImageSize: LayoutSize
        let imagePaddings: LayoutPaddings
        let imageBackgroundCorner: Corner
        let spacingBetweenImageAndTitle: LayoutMetric
        let title: TextStyle
        let titleHorizontalInset: LayoutMetric
        let detail: TextStyle
        let detailHorizontalInset: LayoutMetric
        let spacingBetweenTitleAndDetail: LayoutMetric
        let horizontalPadding: LayoutMetric
        
        init(
            _ family: LayoutFamily
        ) {
            self.background = [
                .backgroundColor(Colors.Defaults.background)
            ]
            self.imageBackground = [
                .backgroundColor(UIColor.clear)
            ]
            
            self.leftImage = [
                .image("icon-import-from-web"),
                .contentMode(.scaleAspectFit)
            ]
            self.leftImageSize = (64, 64)
            
            self.imageSize = (59, 48)
            
            self.rightImage = [
                .image("icon-phone-circle"),
                .contentMode(.scaleAspectFit)
            ]
            self.rightImageSize = (64, 64)
            
            self.imagePaddings = (1,1,1,1)
            self.imageBackgroundCorner = Corner(radius: 0)
            self.spacingBetweenImageAndTitle = 40
            self.title = [
                .textColor(Colors.Text.main),
                .textOverflow(FittingText()),
                .textAlignment(.center)
            ]
            self.titleHorizontalInset = 60
            self.detail = [
                .textColor(Colors.Text.gray),
                .textOverflow(FittingText()),
                .textAlignment(.center)
            ]
            self.detailHorizontalInset = 40
            self.spacingBetweenTitleAndDetail = 12
            self.horizontalPadding = 8
        }
    }
    
}
