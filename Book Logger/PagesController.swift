import UIKit

class PagesController: CollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UISearchControllerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var currentImage = UIImage(named: "no-image")
    let imagePicker = UIImagePickerController()
    
    var book: BookData!

    var filteredPages: [PageData] = []
    var searchIsActive: Bool = false
    let searchController = UISearchController(searchResultsController: nil)
    let searchBarHeight: Int = 50
    
    override func viewDidLoad() {
      imagePicker.delegate = self
      
      searchController.searchResultsUpdater = self
      searchController.searchBar.delegate = self
      searchController.hidesNavigationBarDuringPresentation = false
      searchController.dimsBackgroundDuringPresentation = true
      searchController.obscuresBackgroundDuringPresentation = false
      searchController.searchBar.placeholder = "Search for pages by text..."
      searchController.searchBar.sizeToFit()
      searchController.searchBar.searchBarStyle = .minimal
      searchController.searchBar.becomeFirstResponder()
      
      self.navigationItem.titleView = searchController.searchBar
      definesPresentationContext = true
      collectionView.addSubview(searchController.searchBar)
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: view.bounds.width, height: CGFloat(searchBarHeight))
  }
  
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltering(){
          return filteredPages.count
        }
        return book.pages.count + 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pageCell", for: indexPath) as! PageCell
        
        cell.imageView.layer.borderWidth = 1
        cell.imageView.layer.borderColor = UIColor.lightGray.cgColor
      
      
        // Index 0 is used for 'new page'
        if indexPath.row > 0 {
          let page: PageData
          if isFiltering() {
            page = filteredPages[indexPath.row-1]
          } else {
            page = book.pages[indexPath.row-1]
          }
            // No '+' on the button
            cell.plusLabel.text = ""
            
            // load image from current pages
            cell.imageView.image = page.img
          } else {
            // This cell is for 'new page'
            cell.plusLabel.text = "+"
            cell.imageView.image = nil
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Index 0 is used for 'new page'
        if indexPath.row > 0 {
            // go to existing page
            let page = book.pages[indexPath.row-1]
            sequeToPage(page: page)
        } else {
            // get image, create new page, then segue there
            presentImagePicker()
        }
    }
    
    func sequeToPage(page: PageData) {
        performSegue(withIdentifier: "toPage", sender: page)
    }
    
    func sequeToEditBooks(book: BookData) {
        performSegue(withIdentifier: "toEditPages", sender: book)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPage" {
            // If we are headed to a new page,
            // create that page with the proper image (and transcript)
            let destination = segue.destination as! PageController
            let page = sender as! PageData
            destination.page = page
        } else if segue.identifier == "toEditPages" {
            // If we are headed to a new page,
            // create that page with the proper image (and transcript)
            let destination = segue.destination as! PagesEditController
            destination.book = self.book
        }
    }
    
    @IBAction func presentImagePicker() {
        let imagePickerActionSheet = UIAlertController(title: "Capture/Upload Page",
                                                       message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraButton = UIAlertAction(title: "Take Photo",
                                             style: .default) { (alert) -> Void in
                                                self.imagePicker.delegate = self
                                                self.imagePicker.sourceType = .camera
                                                self.imagePicker.allowsEditing = true
                                                self.present(self.imagePicker, animated: true, completion: nil)
            }
            imagePickerActionSheet.addAction(cameraButton)
        }
        else{
            print("Do not have access to camera, trying photo library")
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let libraryButton = UIAlertAction(title: "Choose Existing",
                                              style: .default) { (alert) -> Void in
                                                self.imagePicker.delegate = self
                                                self.imagePicker.sourceType = .photoLibrary
                                                self.imagePicker.allowsEditing = false // Disallow editing when choosing existing images to speed up the UX.
                                                self.present(self.imagePicker, animated: true, completion: nil)
            }
            imagePickerActionSheet.addAction(libraryButton)
        }
        else {
            print("Do not have access to photo library")
        }
        
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        imagePickerActionSheet.addAction(cancelButton)
        
        present(imagePickerActionSheet, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        /*
         Get the image from the info dictionary.
         If the user edited the image (from the camera), use their edited image. Else use the original (from the library).
         */
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
            currentImage = editedImage
        }
        else if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            currentImage = selectedImage
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
    
    func saveImage(image: UIImage, imageText: String = "Reading page...") -> PageData {
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
  
  // MARK: - Search bar
    func isFiltering() -> Bool {
      return searchController.isActive && !searchBarIsEmpty()
    }

  
  // MARK: - Private instance methods
  
  func searchBarIsEmpty() -> Bool {
    // Returns true if the text is empty or nil
    return searchController.searchBar.text?.isEmpty ?? true
  }
  
  func filterContentForSearchText(_ searchText: String, scope: String = "") {
    filteredPages = book.pages.filter({( page : PageData) -> Bool in
      return page.txt.lowercased().contains(searchText.lowercased())
    })
    collectionView.reloadData()
  }

}

extension PagesController: UISearchResultsUpdating {
  // MARK: - UISearchResultsUpdating Delegate
  func updateSearchResults(for searchController: UISearchController) {
    filterContentForSearchText(searchController.searchBar.text!)
  }
}

