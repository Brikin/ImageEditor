//
//  CollectionController.swift
//  ImageEditor
//
//  Created by Ruslan on 24/01/2018.
//  Copyright © 2018 Ruslan. All rights reserved.
//

import UIKit

class CollectionController: UICollectionViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var imageStore: ImageStore! {
        get {
            return (UIApplication.shared.delegate as? AppDelegate)?.imageStore
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      //  return imageStore.images.count
        return 5
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionCell
        cell.cellImage.image = #imageLiteral(resourceName: "NoImage")
        return cell
    }
    
}
