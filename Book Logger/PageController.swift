import UIKit

class PageController: UIViewController {
    
    @IBOutlet weak var transcriptView: UITextView!
    @IBOutlet weak var pageImageView: UIImageView!
    var page: PageData! = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        pageImageView.image = page.img
        transcriptView.text = page.txt
    }
    
    @IBAction func backToPages(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
