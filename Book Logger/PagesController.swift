import UIKit


class PagesController: CollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    var currentImage = UIImage(named: "no-image")
    let imagePicker = UIImagePickerController()
    
    var book: BookData! = nil
    
    override func viewDidLoad() {
        imagePicker.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return book.pages.count + 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pageCell", for: indexPath) as! PageCell
        
        cell.imageView.layer.borderWidth = 1
        cell.imageView.layer.borderColor = UIColor.lightGray.cgColor
        
        if indexPath.row < book.pages.count {
            // No '+' on the button
            cell.plusLabel.text = ""
            
            // load image from current pages
            cell.imageView.image = book.pages[indexPath.row].img
        } else {
            // this cell is for a new page
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < book.pages.count {
            // go to existing page
            let page = book.pages[indexPath.row]
            sequeToPage(page: page)
        } else {
            // get image, create new page, then segue there
            openCameraButton()
        }
    }
    
    func sequeToPage(page: PageData) {
        print("going to page \(page)")
        performSegue(withIdentifier: "toPage", sender: page)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPage" {
            // If we are headed to a new page,
            // create that page with the proper image (and transcript)
            let destination = segue.destination as! PageController
            let page = sender as! PageData
            destination.page = page
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
  
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
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
      let page = self.saveImage(image: self.currentImage!)
      self.performSegue(withIdentifier: "toPage", sender: page)
    }
  }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
    
    func saveImage(image: UIImage) -> PageData {
        // create new directiory for image / transcript
        
        // The directory is "page" + unix time stamp
        let unixTime = NSDate().timeIntervalSince1970
        let pageDir = book.dir.appendingPathComponent("page\(unixTime)")
        do {
            try FileManager.default.createDirectory(atPath: (pageDir.path), withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError {
            NSLog("Unable to create page directory \(error.debugDescription)")
        }
        
        // new image file
        let imgData = image.pngData()
        let imgName = "page.png"
        let imgURL = pageDir.appendingPathComponent(imgName)
        // new txt file
        let txtData = "I'm a transcript!"
        let txtName = "page.txt"
        let txtURL = pageDir.appendingPathComponent(txtName)
        // write data to page directory
        do {
            try imgData?.write(to: imgURL)
            try txtData.write(to: txtURL, atomically: false, encoding: .utf8)
        } catch {
            print("error saving file:", error)
        }
        
        // create page to pass along to new PageViewController
        let page = PageData(dir: pageDir, img: image, txt: txtData)
        book.pages.append(page)
        
        return page
    }    
    
    @IBAction func backToBooks(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
