// Copyright 2022-2025 Pera Wallet, LDA

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

/// <note>
/// Sort:
/// Alphabetical order.
enum Colors {}

extension Colors {
    enum Alert:
        String,
        Color {
        case content = "Alert/content"
        case negative = "Alert/negative"
        case positive = "Alert/positive"
    }
}

extension Colors {
    enum AlgoIcon:
        String,
        Color {
        case background = "AlgoIcon/bg"
        case icon = "AlgoIcon/icon"
    }
}

extension Colors {
    enum ASATiers:
        String,
        Color {
        case suspiciousIconBackground = "ASA/suspiciousIconBg"
        case suspiciousIconInline = "ASA/suspiciousIconInline"
        case trustedIconBackground = "ASA/trustedIconBg"
        case trustedIconInline = "ASA/trustedIconInline"
        case verifiedIconBackground = "ASA/verifiedIconBg"
        case verifiedIconInline = "ASA/verifiedIconInline"
        case verifiedIconSolidBackground = "ASA/verifiedIconSolidBg"
        case verifiedIconSolidInline = "ASA/verifiedIconSolidInline"
        case asaBarButton = "ASA/asaBarButton"
    }
}

extension Colors {
    enum ASABanners:
        String,
        Color {
        case suspiciousBannerBackground = "ASABanners/suspiciousBannerBg"
        case suspiciousBannerContent = "ASABanners/suspiciousBannerContent"
        case trustedBannerBackground = "ASABanners/trustedBannerBg"
        case trustedBannerContent = "ASABanners/trustedBannerContent"
        case verifiedBannerBackground = "ASABanners/verifiedBannerBg"
        case verifiedBannerContent = "ASABanners/verifiedBannerContent"
    }
}

extension Colors {
    enum Backdrop:
        String,
        Color {
        case modalBackground = "Backdrop/modalBg"
    }
}

extension Colors {
    enum Banner:
        String,
        Color {
        case background = "Banner/bg"
        case button = "Banner/button"
        case iconBackground = "Banner/iconBg"
        case text = "Banner/text"
    }
}

extension Colors {
    enum BottomSheet:
        String,
        Color {
        case line = "BottomSheet/line"
    }
}

extension Colors {
    enum Button {
        enum Float:
            String,
            Color {
            case background = "ButtonFloat/bg"
            case focusBackground = "ButtonFloat/focusBg"
            case iconLighter = "ButtonFloat/iconLighter"
            case iconMain = "ButtonFloat/iconMain"
        }

        enum Ghost:
            String,
            Color {
            case background = "ButtonGhost/bg"
            case disabledBackground = "ButtonGhost/disabledBg"
            case disabledText = "ButtonGhost/disabledText"
            case focusBackground = "ButtonGhost/focusBg"
            case text = "ButtonGhost/text"
        }

        enum Helper:
            String,
            Color {
            case background = "ButtonHelper/bg"
            case disabledBackground = "ButtonHelper/disabledBg"
            case disabledIcon = "ButtonHelper/disabledIcon"
            case focusBackground = "ButtonHelper/focusBg"
            case icon = "ButtonHelper/icon"
            case peraIcon = "ButtonHelper/peraIcon"
        }

        enum Primary:
            String,
            Color {
            case background = "ButtonPrimary/bg"
            case newbackground = "ButtonPrimary/newBg"
            case disabledBackground = "ButtonPrimary/disabledBg"
            case disabledText = "ButtonPrimary/disabledText"
            case focusBackground = "ButtonPrimary/focusBg"
            case text = "ButtonPrimary/text"
            case newText = "ButtonPrimary/newText"
        }

        enum Secondary:
            String,
            Color {
            case background = "ButtonSecondary/bg"
            case disabledBackground = "ButtonSecondary/disabledBg"
            case disabledText = "ButtonSecondary/disabledText"
            case focusBackground = "ButtonSecondary/focusBg"
            case text = "ButtonSecondary/text"
        }

        enum Square:
            String,
            Color {
            case background = "ButtonSquare/bg"
            case focusBackground = "ButtonSquare/focusBg"
            case icon = "ButtonSquare/icon"
            case secondaryBackground = "ButtonSquare/secondaryBg"
            case secondaryIcon = "ButtonSquare/secondaryIcon"
        }
    }
}

extension Colors {
    enum Dapp:
        String,
        Color {
        case moonPay = "Dapp/moonpay"
        case bidali = "Dapp/bidali"
    }
}

extension Colors {
    enum Defaults:
        String,
        Color {
        case background = "Defaults/bg"
        case systemElements = "Defaults/systemElements"
    }
}

extension Colors {
    enum Helpers:
        String,
        Color {
        case heroBackground = "Helpers/heroBg"
        case negative = "Helpers/negative"
        case negativeLighter = "Helpers/negativeLighter"
        case positive = "Helpers/positive"
        case positiveLighter = "Helpers/positiveLighter"
        case success = "Helpers/success"
        case successCheckmark = "Helpers/successCheckmark"
    }
}

extension Colors {
    enum Keyboard:
        String,
        Color {
        case accessoryBackground = "Keyboard/bg"
        case accessoryLine = "Keyboard/line"
    }
}

extension Colors {
    enum Layer:
        String,
        Color {
        case gray = "Layer/gray"
        case grayLighter = "Layer/grayLighter"
        case grayLightest = "Layer/grayLightest"
    }
}

extension Colors {
    enum Link:
        String,
        Color {
        case icon = "Link/icon"
        case primary = "Link/primary"
    }
}

extension Colors {
    enum Modality:
        String,
        Color {
        case background = "Modality/bg"
    }
}

extension Colors {
    enum NFTIcon:
        String,
        Color {
        case icon = "NFTIcon/icon"
        case iconBackground = "NFTIcon/bg"
    }
}

extension Colors {
    enum QRScanner:
        String,
        Color {
        case background = "QRScanner/bg"
    }
}

extension Colors {
    enum Shadows {
        enum Cards:
            String,
            Color {
            case largeShadow1 = "Shadows/Cards/largeShadow1"
            case largeShadow2 = "Shadows/Cards/largeShadow2"
            case shadow1 = "Shadows/Cards/shadow1"
            case shadow2 = "Shadows/Cards/shadow2"
            case shadow3 = "Shadows/Cards/shadow3"
            case shadow4 = "Shadows/Cards/shadow4"
        }

        enum Tab:
            String,
            Color {
            case bottomLine = "Shadows/Tab/bottomLine"
            case bottomLineDark = "Shadows/Tab/bottomLineDark"
        }

        enum TextField:
            String,
            Color {
            case defaultBackground = "Shadows/TextField/defaultBg"
            case errorBackground = "Shadows/TextField/errorBg"
            case typingBackground = "Shadows/TextField/typingBg"
        }
    }
}

extension Colors {
    enum Separator:
        String,
        Color {
        case grayLighter = "Separator/grayLighter"
    }
}

extension Colors {
    enum Switches:
        String,
        Color {
        case background = "Switches/bg"
        case offBackground = "Switches/offBg"
    }
}

extension Colors {
    enum TabBar:
        String,
        Color {
        case background = "Tabbar/bg"
        case button = "Tabbar/button"
        case iconActive = "Tabbar/iconActive"
        case iconDisabled = "Tabbar/iconDisabled"
    }
}

extension Colors {
    enum Testnet:
        String,
        Color {
        case background = "Testnet/bg"
        case text = "Testnet/text"
    }
}

extension Colors {
    enum Text:
        String,
        Color {
        case main = "Text/main"
        case mainDark = "Text/mainDark"
        case gray = "Text/gray"
        case grayLighter = "Text/grayLighter"
        case white = "Text/white"
        case sonicSilver = "Text/sonicSilver"
    }
}

extension Colors {
    enum Toast:
        String,
        Color {
        case background = "Toast/bg"
        case description = "Toast/description"
        case title = "Toast/title"
    }
}

extension Colors {
    enum Wallet:
        String,
        Color {
        case wallet1 = "Wallet/wallet1"
        case wallet1Icon = "Wallet/wallet1Icon"
        case wallet2 = "Wallet/wallet2"
        case wallet2Icon = "Wallet/wallet2Icon"
        case wallet3 = "Wallet/wallet3"
        case wallet3Icon = "Wallet/wallet3Icon"
        case wallet3IconGovernor = "Wallet/wallet3IconGovernor"
        case wallet4 = "Wallet/wallet4"
        case wallet4Icon = "Wallet/wallet4Icon"
        case wallet4IconGovernor = "Wallet/wallet4IconGovernor"
        case wallet5 = "Wallet/wallet5"
        case wallet5Icon = "Wallet/wallet5Icon"
    }
}
