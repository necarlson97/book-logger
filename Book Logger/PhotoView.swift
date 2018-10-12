//
//  PhotoView.swift
//  Book Logger
//
//  Created by Mac on 10/1/18.
//  Copyright © 2018 NC. All rights reserved.
//

import UIKit

class PhotoView: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // if no image is present (we are creating new page)
        openCameraButton()
        // Otherwise load image for this page
    }
    

    @IBOutlet weak var currentImageView: UIImageView!
    
    @IBAction func openCameraButton() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            var imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            print("Do not have access to camera, trying photo library")
            openPhotoLibraryButton()
        }
    }
    
    @IBAction func openPhotoLibraryButton() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            var imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            print("Do not have access to photo library")
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        /*
         Get the image from the info dictionary.
         If no need to edit the photo, use `UIImagePickerControllerOriginalImage`
         instead of `UIImagePickerControllerEditedImage`
         */
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            self.currentImageView.image = editedImage
        }
        
        //Dismiss the UIImagePicker after selection
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.isNavigationBarHidden = false
        self.dismiss(animated: true, completion: nil)
    }
}
