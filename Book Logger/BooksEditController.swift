//
//  BooksEditController.swift
//  Book Logger
//
//  Created by Jordan Chen on 12/5/18.
//  Copyright © 2018 NC. All rights reserved.
//

import UIKit

class BooksEditController: CollectionViewController {
  
  var books:[BookData]!
  @IBOutlet weak var collectionView: UICollectionView!
  
  override func viewDidLoad() {
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return books.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bookCell", for: indexPath) as! BookCell
    
    // load image from current books
    let book = books[indexPath.row]
    
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
  
}
