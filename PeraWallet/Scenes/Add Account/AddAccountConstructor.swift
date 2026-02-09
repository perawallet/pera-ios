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

//   AddAccountConstructor.swift

import SwiftUI

enum AddAccountConstructor {
    
    static func buildScene(legacyConfiguration: ViewControllerConfiguration) -> AddAccountView {
        let model = AddAccountModel(legacyConfiguration: legacyConfiguration)
        return AddAccountView(model: model)
    }
    
    static func buildCompatibilityViewController(legacyConfiguration: ViewControllerConfiguration) -> BaseViewController {
        
        let model = AddAccountModel(legacyConfiguration: legacyConfiguration)
        let controller = AddAccountViewController(model: model)
        let compatibilityController = AddAccountCompatibilityController(configuration: legacyConfiguration, hostingController: controller)
        
        controller.onLegacyNavigationOptionSelected = { [weak compatibilityController] in
            compatibilityController?.moveTo(option: $0)
        }
        
        controller.onDismissRequest = { [weak compatibilityController] in
            compatibilityController?.dismiss()
        }
        
        controller.onLearnMoreTap = { [weak compatibilityController] in
            compatibilityController?.learnMore()
        }
        
        return compatibilityController
    }
}
