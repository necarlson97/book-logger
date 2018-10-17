import UIKit


class PagesController: CollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {

    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bookCell", for: indexPath)
        
        // Configure the cell
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.lightGray.cgColor
        
        // Use this to load the image page
        print(indexPath)
        
        return cell
    }

    @IBAction func newPage(_ sender: Any) {
//        openCameraButton()
        self.performSegue(withIdentifier: "toPage", sender: nil)
    }
    
    @IBOutlet weak var currentImage: UIImage!
    
    @IBAction func openCameraButton() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
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
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            print("Do not have access to photo library")
        }
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        /*
         Get the image from the info dictionary.
         If no need to edit the photo, use `UIImagePickerControllerOriginalImage`
         instead of `UIImagePickerControllerEditedImage`
         */
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            self.currentImage = editedImage
        }
        
        // Segue to page
        self.performSegue(withIdentifier: "toPage", sender: nil)
        // Dismiss the UIImagePicker after selection
        self.dismiss(animated: true)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //        picker.isNavigationBarHidden = false
        self.dismiss(animated: true)
    }
    
    func saveImage(image: UIImage) {
        // get the documents directory url
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // choose a name for your image
        let fileName = "image.jpg"
        // create the destination file url to save your image
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        // get your UIImage jpeg data representation and check if the destination file url already exists
        let data = image.jpegData(compressionQuality: 1.0)
        if data != nil && !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                // writes the image data to disk
                try data?.write(to: fileURL)
                print("file saved")
            } catch {
                print("error saving file:", error)
            }
        }
    }
    
    
}
