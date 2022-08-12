// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   Colors.swift

import MacaroonUIKit
import UIKit

enum Colors {
    /// <todo>
    /// The "Other" group is temporary. When Figma file gets an update
    /// this group should be updated too.

    enum Other: String, Color {
        case chrome = "Other/chrome"
        case dropShadow = "Other/dropShadow"
        case titleDropShadow = "Other/titleDropShadow"
        case qrBackground = "Other/qrBackground"
        case loadingGradient1 = "Other/loadingGradient1"
        case loadingGradient2 = "Other/loadingGradient2"
        case inputSuggestion = "Other/inputSuggestion"
        case inputSuggestionSeparator = "Other/inputSuggestionSeparator"
        case alertShadow1 = "Other/alertShadow1"
        case alertShadow2 = "Other/alertShadow2"

        enum Global: String, Color {
            case gray400 = "Other/Global/gray400"
            case gray800 = "Other/Global/gray800"
            case white = "Other/Global/white"
            case turquoise600 = "Other/turquoise600"
        }
    }
    enum Alert: String, Color {
        case content = "Alert/content"
        case negative = "Alert/negative"
        case positive = "Alert/positive"
    }

    enum AlgoIcon: String, Color {
        case icon = "AlgoIcon/icon"
        case background = "AlgoIcon/bg"
    }

    enum ASATiers: String, Color {
        case suspiciousIconBackground = "ASA/suspiciousIconBg"
        case suspiciousIconInline = "ASA/suspiciousIconInline"
        case trustedIconBackground = "ASA/trustedIconBg"
        case trustedIconInline = "ASA/trustedIconInline"
        case verifiedIconBackground = "ASA/verifiedIconBg"
        case verifiedIconInline = "ASA/verifiedIconInline"
        case verifiedIconSolidBackground = "ASA/verifiedSolidBackground"
        case verifiedIconSolidInline = "ASA/verifiedSolidInline"
    }

    enum ASABanners: String, Color {
        case suspiciousBannerBackground = "ASABanners/suspiciousBannerBg"
        case suspiciousBannerContent = "ASABanners/suspiciousBannerContent"
        case trustedBannerBackground = "ASABanners/trustedIconBg"
        case trustedBannerContent = "ASABanners/trustedBannerContent"
        case verifiedBannerBackground = "ASABanners/verifiedIconBg"
        case verifiedBannerContent = "ASABanners/verifiedBannerContent"
    }

    enum Banner: String, Color {
        case background = "Banner/bg"
        case iconBackground = "Banner/iconBg"
        case button = "Banner/button"
        case text = "Banner/text"
    }

    enum BottomSheet: String, Color {
        case line = "BottomSheet/line"
    }

    enum Button {
        enum Float: String, Color {
            case background = "ButtonFloat/bg"
            case focusBackground = "ButtonFloat/focusBg"
            case iconMain = "ButtonFloat/iconMain"
            case iconLighter = "ButtonFloat/iconLighter"
        }

        enum Ghost: String, Color {
            case background = "ButtonGhost/bg"
            case disabledBackground = "ButtonGhost/disabledBg"
            case focusBackground = "ButtonGhost/focusBg"
            case text = "ButtonGhost/text"
            case disabledText = "ButtonGhost/disabledText"
        }

        enum Helper: String, Color {
            case background = "ButtonHelper/bg"
            case disabledBackground = "ButtonHelper/disabledBg"
            case focusBackground = "ButtonHelper/focusBg"
            case icon = "ButtonHelper/icon"
            case peraIcon = "ButtonHelper/peraIcon"
            case disabledIcon = "ButtonHelper/disabledIcon"
        }

        enum Primary: String, Color {
            case background = "ButtonPrimary/bg"
            case disabledBackground = "ButtonPrimary/disabledBg"
            case focusBackground = "ButtonPrimary/focusBg"
            case text = "ButtonPrimary/text"
            case disabledText = "ButtonPrimary/disabledText"
        }

        enum Secondary: String, Color {
            case background = "ButtonSecondary/bg"
            case disabledBackground = "ButtonSecondary/disabledBg"
            case focusBackground = "ButtonSecondary/focusBg"
            case text = "ButtonSecondary/text"
            case disabledText = "ButtonSecondary/disabledText"
        }

        enum Square: String, Color {
            case background = "ButtonSquare/bg"
            case focusBackground = "ButtonSquare/focusBg"
            case secondaryBackground = "ButtonSquare/secondaryBg"
            case icon = "ButtonSquare/icon"
            case secondaryIcon = "ButtonSquare/secondaryIcon"
        }
    }

    enum Dapp: String, Color {
        case moonpay = "Dapp/moonpay"
    }

    enum Defaults: String, Color {
        case background = "Defaults/bg"
        case systemElements = "Defaults/systemElements"
    }

    enum Helpers: String, Color {
        case heroBackground = "Helpers/heroBg"
        case negative = "Helpers/negative"
        case negativeLighter = "Helpers/negativeLighter"
        case positive = "Helpers/positive"
        case positiveLighter = "Helpers/positiveLighter"
        case success = "Helpers/success"
        case successCheckmark = "Helpers/successCheckmark"
    }

    enum Layer: String, Color {
        case gray = "Layer/gray"
        case grayLighter = "Layer/grayLighter"
        case grayLightest = "Layer/grayLightest"
    }

    enum Link: String, Color {
        case icon = "Link/icon"
        case primary = "Link/primary"
    }

    enum Modality: String, Color {
        case background = "Modality/bg"
    }

    enum NFTIcon: String, Color {
        case icon = "NFTIcon/icon"
        case iconBackground = "NFTIcon/bg"
    }

    enum Switches: String, Color {
        case background = "Switches/bg"
        case offBackground = "Switches/offBg"
    }

    enum TabBar: String, Color {
        case background = "TabBar/bg"
        case button = "TabBar/button"
        case iconActive = "TabBar/iconActive"
        case iconDisabled = "TabBar/iconDisabled"
        case iconNonActive = "TabBar/iconNonActive"
    }

    enum Testnet: String, Color {
        case background = "Testnet/bg"
        case text = "Testnet/text"
    }

    enum Text: String, Color {
        case main = "Text/main"
        case gray = "Text/gray"
        case grayLighter = "Text/grayLighter"
    }

    enum Toast: String, Color {
        case background = "Toast/bg"
        case description = "Toast/description"
        case title = "Toast/title"
    }

    enum Wallet: String, Color {
        case wallet1 = "Wallet/wallet1"
        case wallet1icon = "Wallet/wallet1icon"
        case wallet2 = "Wallet/wallet2"
        case wallet2icon = "Wallet/wallet2icon"
        case wallet3 = "Wallet/wallet3"
        case wallet3icon = "Wallet/wallet3icon"
        case wallet3iconGovernor = "Wallet/wallet3iconGovernor"
        case wallet4 = "Wallet/wallet4"
        case wallet4icon = "Wallet/wallet4icon"
        case wallet4iconGovernor = "Wallet/wallet4iconGovernor"
        case wallet5 = "Wallet/wallet5"
        case wallet5icon = "Wallet/wallet5icon"
    }
}

extension Colors {
    enum Shadows {
        enum Cards: String, Color {
            case shadow1 = "Shadows/Cards/shadow1"
            case shadow2 = "Shadows/Cards/shadow2"
            case shadow3 = "Shadows/Cards/shadow3"
        }

        enum Tab: String, Color {
            case bottomLine = "Shadows/Tab/bottomLine"
        }

        enum TextField: String, Color {
            case defaultBackground = "Shadows/TextField/defaultBg"
            case errorBackground = "Shadows/TextField/errorBg"
            case typingBackground = "Shadows/TextField/typingBg"
        }
    }
}
