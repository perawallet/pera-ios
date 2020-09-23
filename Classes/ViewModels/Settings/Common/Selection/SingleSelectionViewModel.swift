//
//  SingleSelectionViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 17.09.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class SingleSelectionViewModel {
    
    private(set) var title: String?
    private(set) var isSelected = false
    
    init(title: String?, isSelected: Bool) {
        setTitle(title: title)
        setSelected(isSelected: isSelected)
    }
    
    private func setTitle(title: String?) {
        self.title = title
    }
    
    private func setSelected(isSelected: Bool) {
        self.isSelected = isSelected
    }
}
