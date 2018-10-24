import UIKit


class PagesController: CollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var currentImage = UIImage(named: "no-image")
    var pages:[(UIImage, String)]!
    let imagePicker = UIImagePickerController()
    var bookDir:NSURL!
    
    override func viewDidLoad() {
        imagePicker.delegate = self
        pages = []
        
        

    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count + 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pageCell", for: indexPath) as! PageCell
        
        cell.imageView.layer.borderWidth = 1
        cell.imageView.layer.borderColor = UIColor.lightGray.cgColor
        
        if indexPath.row < pages.count {
            // load image from current pages
            cell.imageView.image = pages[indexPath.row].0
        } else {
            // this cell is for a new page
        }
        
        return cell
    }
    
    @IBAction func newPage(_ sender: Any) {
        openCameraButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPage" {
            // If we are headed to a new page,
            // create that page with the proper image (and transcript)
            let destination = segue.destination as! PageController
            destination.pageImage = currentImage
        }
    }
    
    @IBAction func openCameraButton() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
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
            currentImage = editedImage
        }
        
        // Dismiss the UIImagePicker after selection
        self.dismiss(animated: true) {
            // Segue to new page after image capture
            self.saveImage(image: self.currentImage!)
            self.performSegue(withIdentifier: "toPage", sender: nil)
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
    
    func saveImage(image: UIImage) {
        // create new directiory for image / transcript
        let pageDir = bookDir.appendingPathComponent("page")
        do {
            try FileManager.default.createDirectory(atPath: (pageDir?.path)!, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError {
            NSLog("Unable to create page directory \(error.debugDescription)")
        }
        
        // new image file
        let imgData = image.pngData()
        let imgName = "page.png"
        let imgURL = pageDir?.appendingPathComponent(imgName)
        // new txt file
        let txtData = "I'm a transcript!"
        let txtName = "page.txt"
        let txtURL = pageDir?.appendingPathComponent(txtName)
        // write data to page directory
        do {
            try imgData?.write(to: imgURL!)
            try txtData.write(to: txtURL!, atomically: false, encoding: .utf8)
        } catch {
            print("error saving file:", error)
        }
    
    }    
    
}
