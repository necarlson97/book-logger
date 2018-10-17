import UIKit


class BooksController: CollectionViewController {
    
    var books:[(UIImage, String)]!
    
    override func viewDidLoad() {
        books = []
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bookCell", for: indexPath) as! BookCell
        
        if indexPath.row < books.count {
            // load image from current books
            cell.bookImageView.image = books[indexPath.row].0
        } else {
            // this cell is for a new book
        }
        
        cell.bookImageView.layer.borderWidth = 1
        cell.bookImageView.layer.borderColor = UIColor.lightGray.cgColor
        cell.bgImageView.layer.borderWidth = 1
        cell.bgImageView.layer.borderColor = UIColor.lightGray.cgColor
        
        return cell
    }
    
}
