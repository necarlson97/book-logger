//
//  BookCell.swift
//  Book Logger
//
//  Created by Mac on 10/17/18.
//  Copyright © 2018 NC. All rights reserved.
//

import UIKit

class BookCell: UICollectionViewCell {
    
    @IBOutlet weak var bookImageView: UIImageView!
    
    @IBOutlet weak var bgImageView: UIImageView!
    
    @IBOutlet weak var plusLabel: UILabel!
  
    // Variables only for edit view
    var indexPath: IndexPath!
    var editController: BooksEditController!
    
    @IBAction func deleteThisCell(_ sender: Any) {
      editController.deleteCell(cell: self)
    }
}
