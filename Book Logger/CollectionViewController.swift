

import UIKit

class PageData {
    // Data storage object for a single page
    
    // camera / photo library image
    var img: UIImage!
    // ocr transcript for image
    var txt: String!
    // directory this page is saved to
    var dir: URL!
    
    init(dir: URL, img: UIImage?, txt: String?) {
        // If data was improperly set / cannot be found, use error indicators
        self.dir = dir
        self.img = img
        if img == nil {
            self.img = UIImage(named: "no-image")!
        }
        self.txt = txt
        if txt == nil {
            self.txt = "ERROR: image transcript not loded"
        }
    }
    

}

class BookData {
    // Data storage object for a book
    
    // array of pages that form the book
    var pages:[PageData]!
    // directory this book is saved to
    var dir: URL!
    
    init(dir: URL, pages:[PageData]) {
        self.dir = dir
        self.pages = pages
    }
}


class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    override func viewDidLoad() {
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "overrideThisFunction", for: indexPath)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (collectionView.bounds.size.width/2)
        let ratio = collectionView.bounds.size.height / collectionView.bounds.size.width
        // we have an offset here so cell is cutoff, making scrollability obvious
        let h = (w * ratio) - 10
        return CGSize(width: w, height: h);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

}
