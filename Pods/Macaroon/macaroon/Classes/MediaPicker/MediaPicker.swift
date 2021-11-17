// Copyright © 2019 hipolabs. All rights reserved.

import CoreServices
import Foundation
import Photos
import UIKit

open class MediaPicker: NSObject {
    public var allowsEditing = true

    public let mediaTypes: [MediaType]
    public let sourceTypes: [SourceType]

    private var notifierWhenPickedMedia: ((Media) -> Void)?

    private weak var presentingScreen: UIViewController?

    public init(
        presentingScreen: UIViewController,
        mediaTypes: [MediaType] = [.photo],
        sourceTypes: [SourceType] = [.camera, .photoLibrary]
    ) {
        self.presentingScreen = presentingScreen
        self.mediaTypes = mediaTypes
        self.sourceTypes = sourceTypes.filter { $0.isAvailable() }
    }

    open func open() {
        switch sourceTypes.count {
        case 0:
            return
        case 1:
            openSource(sourceTypes[0])
        default:
            openSourcePicker()
        }
    }

    open func openSourcePicker() {
        /// <todo> Make the title localized.
        let sourcePicker = UIAlertController(title: "Select Source", message: nil, preferredStyle: .actionSheet)
        sourceTypes.forEach { sourceType in
            sourcePicker.addAction(
                UIAlertAction(title: sourceType.description, style: .default) { [unowned self] _ in
                    self.openSource(sourceType)
                }
            )
        }
        /// <todo> Make the title localized.
        sourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        presentingScreen?.present(sourcePicker, animated: true)
    }

    open func openSource(_ sourceType: SourceType) {
        let controller = UIImagePickerController()
        controller.sourceType = sourceType.asSystem()
        controller.mediaTypes = mediaTypes
            .filter({ $0.isAvailable(for: sourceType) })
            .map({ $0.asSystem() })
        controller.allowsEditing = allowsEditing
        controller.delegate = self

        presentingScreen?.present(controller, animated: true)
    }

    open func close() {
        if let presentingScreen = presentingScreen.unwrapConditionally(where: { $0.presentedViewController is UIImagePickerController }) {
            presentingScreen.dismiss(animated: true)
        }
    }
}

extension MediaPicker {
    public func notifyWhenPickedPhoto(execute: @escaping (Photo) -> Void) {
        notifierWhenPickedMedia = {
            if let photo = $0 as? Photo {
                execute(photo)
            }
        }
    }
}

extension MediaPicker {
    public enum SourceType {
        case camera
        case photoLibrary
    }

    public enum MediaType {
        case photo
    }
}

extension MediaPicker: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.presentingViewController?.dismiss(animated: true)
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer {
            notifierWhenPickedMedia = nil
            picker.presentingViewController?.dismiss(animated: true)
        }

        if let pickedImage = (info[.editedImage] ?? info[.originalImage]) as? UIImage {
            let photo = Photo(image: pickedImage, url: info[.imageURL] as? URL, asset: info[.phAsset] as? PHAsset)
            notifierWhenPickedMedia?(photo)
            return
        }
    }
}

extension MediaPicker.SourceType: CustomStringConvertible {
    public var description: String {
        /// <todo> Make the descriptions localized.
        switch self {
        case .camera:
            return "Camera"
        case .photoLibrary:
            return "Photo Library"
        }
    }

    public func asSystem() -> UIImagePickerController.SourceType {
        switch self {
        case .camera:
            return .camera
        case .photoLibrary:
            return .photoLibrary
        }
    }

    public func isAvailable() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(asSystem())
    }
}

extension MediaPicker.MediaType {
    public func asSystem() -> String {
        switch self {
        case .photo:
            return kUTTypeImage as String
        }
    }

    public func isAvailable(for sourceType: MediaPicker.SourceType) -> Bool {
        return UIImagePickerController.availableMediaTypes(for: sourceType.asSystem()).unwrap({ $0.contains(asSystem()) }, or: false)
    }
}
