import UIKit
import TesseractOCR

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
            // This cell is for 'new page'
            cell.plusLabel.text = "+"
            cell.imageView.image = nil
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
    // Tesseract Image Recognition
    func performImageRecognition(_ image: UIImage) -> String {
      if let tesseract = G8Tesseract(language: "eng") {
        tesseract.engineMode = .tesseractCubeCombined // Run Tesseract and Cube for best accuracy
        tesseract.pageSegmentationMode = .auto // Have Tesseract automatically recognize paragraph breaks
        tesseract.image = image.g8_blackAndWhite() // Preprocessing step
        tesseract.recognize() // run image recognition
        return tesseract.recognizedText
      }
      let errorMessage = "Could not initiate image recongiton."
      return errorMessage
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
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    /*
     Get the image from the info dictionary.
     If no need to edit the photo, use `UIImagePickerControllerOriginalImage`
     instead of `UIImagePickerControllerEditedImage`
     */
    if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
      currentImage = editedImage
    }
    
    // Dismiss the UIImagePicker after selection
    self.dismiss(animated: true) {
      // Segue to new page after image capture
      
      // Scale image for OCR
      let scaledImage = self.currentImage!.scaleImage(640)!
      // Perform OCR and retrieve the recognized text
      let OCRText = self.performImageRecognition(scaledImage)
      let page = self.saveImage(image: self.currentImage!, imageText: OCRText)
      self.performSegue(withIdentifier: "toPage", sender: page)
    }
  }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
    
  func saveImage(image: UIImage, imageText: String = "I'm a transcript!") -> PageData {
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
        let imgData = UIImagePNGRepresentation(image)
        let imgName = "page.png"
        let imgURL = pageDir.appendingPathComponent(imgName)
        // new txt file
        let txtData = imageText
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

// MARK: - UIImage extension
extension UIImage {
  func scaleImage(_ maxDimension: CGFloat) -> UIImage? {
    var scaledSize = CGSize(width: maxDimension, height: maxDimension)
    
    if size.width > size.height {
      let scaleFactor = size.height / size.width
      scaledSize.height = scaledSize.width * scaleFactor
    }
    else {
      let scaleFactor = size.width / size.height
      scaledSize.width = scaledSize.height * scaleFactor
    }
    
    UIGraphicsBeginImageContext(scaledSize)
    draw(in: CGRect(origin: .zero, size: scaledSize))
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return scaledImage
  }
}
