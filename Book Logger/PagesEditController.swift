import UIKit

class PagesEditController: CollectionViewController {
    
    var book: BookData!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return book.pages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pageCell", for: indexPath) as! PageCell
        
        // load image from current pages
        cell.imageView.image = book.pages[indexPath.row].img
        
        cell.indexPath = indexPath
        cell.editController = self
        
        return cell
    }
    
    func deleteCell(cell: PageCell) {
        // This function is called by a cell when its delete button is pressed
        
        // remove from array
        let page = book.pages[cell.indexPath.row]
        book.pages.remove(at: cell.indexPath.row)
        // remove from collection viewbook.dir.relativePath
        collectionView.deleteItems(at: [cell.indexPath])
        // remove from disk
        do {
            try FileManager.default.removeItem(atPath: page.dir.relativePath)
        } catch {
            print("error deleting file:", error)
        }
    }
    
    @IBAction func backToPagess(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
