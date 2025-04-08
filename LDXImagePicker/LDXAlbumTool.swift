//
//  LDXAlbumTool.swift
//  TestDemo
//
//  Created by Mac-Mini on 2025/4/8.
//

import UIKit
import Photos
import LDXImagePicker

class LDXAlbumBlock: NSObject {
    var selectBlock: ((_ selectAssets: [PHAsset]) -> Void)?
    var cancelBlock: (() -> Void)?
}

extension LDXAlbumBlock: LDXImagePickerControllerDelegate {
    func ldx_imagePickerControllerDidCancel(_ imagePickerController: LDXImagePickerController!) {
        DispatchQueue.main.async {
            imagePickerController.dismiss(animated: true)
        }
        cancelBlock?()
        albumObjects.removeAll { $0 === self }
    }
    func ldx_imagePickerController(_ imagePickerController: LDXImagePickerController!, didFinishPickingAssets assets: [Any]!) {
        DispatchQueue.main.async {
            imagePickerController.dismiss(animated: true)
        }
        selectBlock?(assets as! [PHAsset])
        albumObjects.removeAll { $0 === self }
    }
}

nonisolated(unsafe) var albumObjects = [LDXAlbumBlock]()
public class LDXAlbumTool: NSObject {
    @MainActor static func showAlbum(vc: UIViewController, selectBlock: @escaping (_ selectAssets: [PHAsset]) -> Void, cancelBlock: @escaping (() -> Void)) {
        let albumBlock = LDXAlbumBlock()
        albumObjects.append(albumBlock)
        albumBlock.selectBlock = selectBlock
        albumBlock.cancelBlock = cancelBlock
        
        let picker = LDXImagePickerController()
        picker.delegate = albumBlock
        picker.mediaType = .any
        picker.allowsMultipleSelection = true
        picker.showsNumberOfSelectedAssets = true
        picker.numberOfColumnsInPortrait = 3
        picker.modalPresentationStyle = .overFullScreen
        vc.present(picker, animated: true)
    }

}
