import UIKit

class BooksController: CollectionViewController {
    
    var library:LibraryData!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        library = LibraryData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return library.books.count + 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bookCell", for: indexPath) as! BookCell
        
        // Index 0 is used for 'new book'
        if indexPath.row > 0 {
            // No '+' on the button
            cell.plusLabel.text = ""
            
            // load image from current books
            let book = library.books[indexPath.row-1]
            
            // Set front image to first page
            if book.pages.count > 0 {
                cell.bookImageView.image = book.pages[0].img
            } else {
                cell.bookImageView.image = nil
            }
            
            // if there are more images, set back image to second page
            if book.pages.count > 1 {
                cell.bgImageView.image = book.pages[1].img
            } else {
                cell.bgImageView.image = nil
            }
        } else {
            // this cell is for a new book
            cell.plusLabel.text = "+"
            cell.bgImageView.image = nil
            cell.bookImageView.image = nil
        }
        
        cell.bookImageView.layer.borderWidth = 1
        cell.bookImageView.layer.borderColor = UIColor.lightGray.cgColor
        cell.bgImageView.layer.borderWidth = 1
        cell.bgImageView.layer.borderColor = UIColor.lightGray.cgColor
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Index 0 is used for 'new book'
        if indexPath.row > 0 {
            // go to existing book
            let book = library.books[indexPath.row-1]
            sequeToBook(book: book)
        } else {
            // create new book, then segue there
            sequeToNewBook()
        }
    }
    
    func sequeToNewBook() {
        // create new book directory
        let unixTime = NSDate().timeIntervalSince1970
        let bookDir = library.dir.appendingPathComponent("book\(unixTime)")
        do {
            try FileManager.default.createDirectory(atPath: (bookDir.path), withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            NSLog("Unable to create book directory \(error.debugDescription)")
        }
        
        let book = BookData(dir: bookDir, pages:[])
        library.books.append(book)
        performSegue(withIdentifier: "toPages", sender: book)
    }
    
    func sequeToBook(book: BookData) {
        performSegue(withIdentifier: "toPages", sender: book)
    }
    
    func sequeToEditBooks() {
        performSegue(withIdentifier: "toEditBooks", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Before we move to a PagesViewController, set the correct BookData (using sender)
        if segue.identifier == "toPages" {
            let pagesVC = segue.destination as! PagesController
            let book = sender as! BookData
            pagesVC.book = book
        } else if segue.identifier == "toEditBooks" {
            let editVC = segue.destination as! BooksEditController
            editVC.library = self.library
        }
    }
    
    
    
}
