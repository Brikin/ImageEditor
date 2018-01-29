//
//  CollectionCell.swift
//  ImageEditor
//
//  Created by Ruslan on 25/01/2018.
//  Copyright © 2018 Ruslan. All rights reserved.
//

import UIKit


class CollectionCell: UICollectionViewCell {
    
    var progressBarStatus:Float = 0.0
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    
}
