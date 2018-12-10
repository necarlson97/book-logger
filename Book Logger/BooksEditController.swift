import UIKit

class BooksEditController: CollectionViewController {
    
    var library:LibraryData!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return library.books.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bookCell", for: indexPath) as! BookCell
        
        // load image from current books
        let book = library.books[indexPath.row]
        
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
        
        cell.bookImageView.layer.borderWidth = 1
        cell.bookImageView.layer.borderColor = UIColor.lightGray.cgColor
        cell.bgImageView.layer.borderWidth = 1
        cell.bgImageView.layer.borderColor = UIColor.lightGray.cgColor
        
        cell.indexPath = indexPath
        cell.editController = self
        
        return cell
    }
    
    func deleteCell(cell: BookCell) {
        // This function is called by a cell when its delete button is pressed
        
        // remove from array
        let book = library.books[cell.indexPath.row]
        library.books.remove(at: cell.indexPath.row)
        // remove from collection viewbook.dir.relativePath
        collectionView.deleteItems(at: [cell.indexPath])
        // remove from disk
        do {
            try FileManager.default.removeItem(atPath: book.dir.relativePath)
        } catch {
            print("error deleting folder:", error)
        }
    }
    
    @IBAction func backToBooks(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
