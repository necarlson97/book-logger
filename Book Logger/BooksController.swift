import UIKit

class BooksController: CollectionViewController {
    
    var books:[BookData]!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    override func viewDidLoad() {
       books = getBooks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count + 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bookCell", for: indexPath) as! BookCell
        
        // Index 0 is used for 'new book'
        if indexPath.row > 0 {
            // No '+' on the button
            cell.plusLabel.text = ""
            
            // load image from current books
            let book = books[indexPath.row-1]

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
            let book = books[indexPath.row-1]
            sequeToBook(book: book)
        } else {
            // create new book, then segue there
            sequeToNewBook()
        }
    }
    
    func sequeToNewBook() {
        // create new book directory
        let unixTime = NSDate().timeIntervalSince1970
        let bookDir = docDir.appendingPathComponent("book\(unixTime)")
        do {
            try FileManager.default.createDirectory(atPath: (bookDir.path), withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            NSLog("Unable to create book directory \(error.debugDescription)")
        }
        
        let book = BookData(dir: bookDir, pages:[])
        books.append(book)
        performSegue(withIdentifier: "toPages", sender: book)
    }
    
    func sequeToBook(book: BookData) {
        performSegue(withIdentifier: "toPages", sender: book)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Before we move to a PagesViewController, set the correct BookData (using sender)
        if segue.identifier == "toPages" {
            let pagesVC = segue.destination as! PagesController
            let book = sender as! BookData
            pagesVC.book = book
        }
    }
    
    func getBooks() -> [BookData] {
        var loadBooks:[BookData] = []
        
        do {
            // Get all book folders, iterate through
            let bookDirs = try FileManager.default.contentsOfDirectory(at: docDir, includingPropertiesForKeys: nil).filter({ $0.hasDirectoryPath })
            for bookDir in bookDirs {
                // create a new book with empty pages
                let book:BookData = BookData(dir: bookDir, pages: [])
                // get all page folders, iterate through
                let pageDirs = try FileManager.default.contentsOfDirectory(at: bookDir, includingPropertiesForKeys: nil).filter({ $0.hasDirectoryPath })
                for pageDir in pageDirs {
                    // get page image and page transcript text
                    
                    // load image from file
                    let imagePath = pageDir.appendingPathComponent("page.png")
                    let imageData = NSData(contentsOf: imagePath)!
                    let img = UIImage(data: imageData as Data)
                    // Load text from file
                    let txtPath = pageDir.appendingPathComponent("page.txt")
                    let txt = try String(contentsOf: txtPath, encoding: .utf8)
                    
                    // Add new page to pages
                    let page = PageData(dir: pageDir, img: img, txt: txt)
                    book.pages.append(page)
                }
                // Add new book to books
                loadBooks.append(book)
            }
        } catch let error{
            print("error getting books: ", error)
        }
        return loadBooks
        
    }
    
}
