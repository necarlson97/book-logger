import UIKit


class BooksController: CollectionViewController {
    
    override func viewDidLoad() {
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bookCell", for: indexPath)
        
        // Configure the cell
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.lightGray.cgColor
        
        // Use this to load the image page
        print(indexPath)
        
        return cell
    }
    
}
