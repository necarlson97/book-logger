import UIKit


class BooksController: CollectionViewController {
    
    var books:[[(UIImage, String)]]!
    
    let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    override func viewDidLoad() {
        books = getBooks()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count + 1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPages" {
            // If we are headed to a new book,
            // create a new directory for it
            let destination = segue.destination as! PagesController
            let bookDir = docDir.appendingPathComponent("book")
            do {
                try FileManager.default.createDirectory(atPath: (bookDir.path), withIntermediateDirectories: true, attributes: nil)
            }
            catch let error as NSError {
                NSLog("Unable to create book directory \(error.debugDescription)")
            }
            destination.bookDir = bookDir as NSURL
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bookCell", for: indexPath) as! BookCell
        
        if indexPath.row < books.count {
            // load image from current books
            let book = books[indexPath.row]

            // Set front image to first page
            cell.bookImageView.image = book[0].0
            
            // if there are more images, set back image to second page
            if book.count > 1 {
                cell.bgImageView.image = book[1].0

            }
        } else {
            // this cell is for a new book
        }
        
        cell.bookImageView.layer.borderWidth = 1
        cell.bookImageView.layer.borderColor = UIColor.lightGray.cgColor
        cell.bgImageView.layer.borderWidth = 1
        cell.bgImageView.layer.borderColor = UIColor.lightGray.cgColor
        
        return cell
    }
    
    func newBook() {
        
    }
    
    func getBooks() -> [[(UIImage, String)]] {
        var loadBooks:[[(UIImage, String)]] = []
        
        do {
            // Get all book folders, iterate through
            let bookDirs = try FileManager.default.contentsOfDirectory(at: docDir, includingPropertiesForKeys: nil)
            for bookDir in bookDirs {
                var pages:[(UIImage, String)] = []
                // get all page folders, iterate through
                let pageDirs = try FileManager.default.contentsOfDirectory(at: bookDir, includingPropertiesForKeys: nil)
                for pageDir in pageDirs {
                    // get page image and page transcript text
                    let imagePath = pageDir.appendingPathComponent("page.png")
                    let img = UIImage(contentsOfFile: imagePath.absoluteString)
                    let txtPath = pageDir.appendingPathComponent("page.txt")
                    let txt = try String(contentsOf: txtPath, encoding: .utf8)
                    // Add new page to pages
                    pages.append((img!, txt))
                }
                // Add new book to books
                loadBooks.append(pages)
            }
        } catch let error{
            print("error getting books: ", error)
        }
        return loadBooks
        
    }
    
}
