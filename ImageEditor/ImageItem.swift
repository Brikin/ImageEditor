//
//  ImageItem.swift
//  ImageEditor
//
//  Created by Ruslan on 29/01/2018.
//  Copyright © 2018 Ruslan. All rights reserved.
//

import UIKit


class ImageItem {
    
    var progress: Float
    var image: UIImage?
    
    init(initialImage: UIImage) {
        progress = 0.0
        image = initialImage
    }
    
    var isProgressBarVisible: Bool {
        get { return progress < 1.0 }
    }
}
