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
//   AppColors.swift

import Foundation
import MacaroonUIKit

/// <note>  This naming is temporary to not coincide with current `Colors` file.
enum AppColors {
    enum Shared {}
    enum Components {}
    enum SendTransaction {}
}

extension AppColors.Shared {
    enum Global: String, Color {
        case white = "Shared/Global/white"
        case gray400 = "Shared/Global/gray400"
        case gray800 = "Shared/Global/gray800"
        case turquoise600 = "Shared/Global/turquoise600"
    }

    enum System: String, Color {
        case background = "Shared/System/background"
        case systemElements = "Shared/System/systemElements"
    }

    enum Layer: String, Color {
        case gray = "Shared/Layer/gray"
        case grayLighter = "Shared/Layer/grayLighter"
        case grayLightest = "Shared/Layer/grayLightest"
    }

    enum Modality: String, Color {
        case background = "Shared/Modality/background"
    }

    enum Helpers: String, Color {
        case negative = "Shared/Helpers/negative"
        case negativeLighter = "Shared/Helpers/negativeLighter"
        case positive = "Shared/Helpers/positive"
    }

    enum Shadow: String, Color {
        case `default` = "Shared/Shadow/default"
    }
}

extension AppColors.Components {
    enum Text: String, Color {
        case main = "Components/Text/main"
        case gray = "Components/Text/gray"
        case grayLighter = "Components/Text/grayLighter"
    }
}

extension AppColors.Components {
    enum Button {
        enum Primary: String, Color {
            case background = "Components/Button/Primary/background"
            case focusBackground = "Components/Button/Primary/focusBackground"
            case disabledBackground = "Components/Button/Primary/disabledBackground"
            case text = "Components/Button/Primary/text"
            case disabledText = "Components/Button/Primary/disabledText"
        }

        enum Secondary: String, Color {
            case background = "Components/Button/Secondary/background"
            case focusBackground = "Components/Button/Secondary/focusBackground"
            case disabledBackground = "Components/Button/Secondary/disabledBackground"
            case text = "Components/Button/Secondary/text"
            case disabledText = "Components/Button/Secondary/disabledText"
        }

        enum Ghost: String, Color {
            case background = "Components/Button/Ghost/background"
            case focusBackground = "Components/Button/Ghost/focusBackground"
            case disabledBackground = "Components/Button/Ghost/disabledBackground"
            case text = "Components/Button/Ghost/text"
            case disabledText = "Components/Button/Ghost/disabledText"
        }

        enum TransactionShadow: String, Color {
            case background = "Components/Button/Shadow/background"
            case text = "Components/Button/Shadow/text"
        }
    }
}

extension AppColors.Components {
    enum Link: String, Color {
        case primary = "Components/Link/primary"
        case icon = "Components/Link/icon"
    }
}

extension AppColors.Components {
    enum Wallet {
        enum Wallet1: String, Color {
            case wallet1 = "Components/Wallet/Wallet1/wallet1"
            case icon = "Components/Wallet/Wallet1/icon"
        }

        enum Wallet2: String, Color {
            case wallet2 = "Components/Wallet/Wallet2/wallet2"
            case icon = "Components/Wallet/Wallet2/icon"
        }

        enum Wallet3: String, Color {
            case wallet3 = "Components/Wallet/Wallet3/wallet3"
            case icon = "Components/Wallet/Wallet3/icon"
        }
    }
}

extension AppColors.Components {
    enum BottomSheet: String, Color {
        case line = "Components/BottomSheet/line"
    }
}

extension AppColors.Components {
    enum TabBar: String, Color {
        case button = "Components/TabBar/button"
        case background = "Components/TabBar/background"
    }
}

extension AppColors.Components {
    enum Tab: String, Color {
        case bottomLine = "Components/Tab/bottomLine"
    }
}

extension AppColors.Components {
    enum TextField: String, Color {
        case defaultBackground = "Components/TextField/defaultBackground"
        case typingBackground = "Components/TextField/typingBackground"
        case errorBackground = "Components/TextField/errorBackground"
    }
}

extension AppColors.Components {
    enum QR: String, Color {
        case background = "Components/QR/background"
    }
}

extension AppColors.SendTransaction {
    enum Shadow: String, Color {
        case first = "SendTransaction/Shadow/account-first"
        case second = "SendTransaction/Shadow/account-second"
        case third = "SendTransaction/Shadow/account-third"
    }
}
