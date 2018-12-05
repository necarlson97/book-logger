//
//  PageCell.swift
//  Book Logger
//
//  Created by Mac on 10/17/18.
//  Copyright © 2018 NC. All rights reserved.
//

import UIKit

class PageCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var plusLabel: UILabel!
    
    // Variables only for edit view
    var indexPath: IndexPath!
    var editController: PagesEditController!
    
    @IBAction func deleteThisCell(_ sender: Any) {
        editController.deleteCell(cell: self)
    }
}
