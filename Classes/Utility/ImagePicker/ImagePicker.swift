//
//  ImagePicker.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 1.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import Photos

protocol ImagePickerDelegate: class {
    
    func imagePicker(didPick image: UIImage, withInfo info: [String: Any])
}

class ImagePicker: NSObject {
    
    weak var delegate: ImagePickerDelegate?
    
    private let imagePickerViewController: UIImagePickerController
    
    override init() {
        self.imagePickerViewController = UIImagePickerController()

        super.init()
        
        configureImagePicker()
    }
    
    private func configureImagePicker() {
        imagePickerViewController.navigationBar.isTranslucent = false
        imagePickerViewController.delegate = self
        imagePickerViewController.allowsEditing = false
        imagePickerViewController.sourceType = .photoLibrary
    }
    
    func present(from viewController: UIViewController) {
        viewController.present(imagePickerViewController, animated: true, completion: nil)
    }
}

// MARK: UIImagePickerControllerDelegate

extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        
        let info = Dictionary(uniqueKeysWithValues: info.map { key, value in (key.rawValue, value) })
        
        guard let pickedImage = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage,
            let delegate = self.delegate else {
                return
        }
        
        picker.dismiss(animated: true) {
            delegate.imagePicker(didPick: pickedImage, withInfo: info)
        }
        
        return
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
