import UIKit

class PageController: UIViewController {
    
    @IBOutlet weak var pageImageView: UIImageView!
    var pageImage = UIImage(named: "no-image")

    override func viewDidLoad() {
        super.viewDidLoad()

        pageImageView.image = pageImage
    }
    
    
    
}
