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
<<<<<<< HEAD:Classes/Demo/BlockCycle.swift
//   BlockCycle.swift


import Foundation

protocol BlockCycle: AnyObject {
    typealias NotificationHandler = () -> Void

    func notify(
        queue: DispatchQueue,
        execute handler: @escaping NotificationHandler
    )
    func startListening()
    func stopListening()
}
=======
//   NoContentViewModel.swift

import Foundation

protocol NoContentViewModel: ResultViewModel {}

>>>>>>> accounts-management-refactor:Classes/Shared/Views/Common/EmptyStates/NoContentView/NoContentViewModel.swift
