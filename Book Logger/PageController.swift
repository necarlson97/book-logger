import UIKit
import TesseractOCR

class PageController: UIViewController {
    
    @IBOutlet weak var transcriptView: UITextView!
    @IBOutlet weak var pageImageView: UIImageView!
    var page: PageData! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageImageView.image = page.img
        transcriptView.text = page.txt
        
        DispatchQueue.global(qos: .background).async {
            let OCRText = self.generateTranscript()
            
            DispatchQueue.main.async {
                self.updateTranscriptView(OCRText: OCRText)
            }
        }
        
        // Move view down for keyboard comming up
        NotificationCenter.default.addObserver(self, selector: #selector(PageController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PageController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        // Push origin up to make way for keyboard
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        // Reset origin to normal
        self.view.frame.origin.y = 0
    }

    
    
    
    @IBAction func backToPages(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func generateTranscript() -> String {
        // Scale image for OCR
        let scaledImage = page.img.scaleImage(640)!
        // Perform OCR and retrieve the recognized text
        let OCRText = self.performImageRecognition(scaledImage)
        // Save to file
        let txtData = OCRText
        let txtName = "page.txt"
        let txtURL = page.dir.appendingPathComponent(txtName)
        // overwrite data to page directory
        do {
            try FileManager.default.removeItem(atPath: txtURL.absoluteString)
            try txtData.write(to: txtURL, atomically: false, encoding: .utf8)
        } catch {
            print("error saving file:", error)
        }
        return OCRText
    }
    
    func updateTranscriptView(OCRText: String) {
        // update view
        page.txt = OCRText
        transcriptView.text = page.txt
    }
    
    // Tesseract Image Recognition
    func performImageRecognition(_ image: UIImage) -> String {
        if let tesseract = G8Tesseract(language: "eng") {
            tesseract.engineMode = .tesseractCubeCombined // Run Tesseract and Cube for best accuracy
            tesseract.pageSegmentationMode = .auto // Have Tesseract automatically recognize paragraph breaks
            tesseract.image = image.g8_blackAndWhite() // Preprocessing step
            tesseract.recognize() // run image recognition
            return tesseract.recognizedText
        }
        else {
            let errorMessage = "Could not initiate image recognition."
            return errorMessage
        }
    }
    
}

// MARK: - UIImage extension
extension UIImage {
    func scaleImage(_ maxDimension: CGFloat) -> UIImage? {
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        
        if size.width > size.height {
            let scaleFactor = size.height / size.width
            scaledSize.height = scaledSize.width * scaleFactor
        }
        else {
            let scaleFactor = size.width / size.height
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
}
