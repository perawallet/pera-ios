//
//  ImagePicker.swift

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
        imagePickerViewController.allowsEditing = true
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
        
        var image: UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage.rawValue] as? UIImage {
            image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage {
            image = originalImage
        }
        
        guard let pickedImage = image,
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
