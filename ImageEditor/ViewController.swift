//
//  ViewController.swift
//  ImageEditor
//
//  Created by Ruslan on 24/01/2018.
//  Copyright © 2018 Ruslan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var items: [ImageItem] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func halfMirrorButtonTapped(_ sender: Any) {
        doConversion(type: .halfMirror)
    }
    
    @IBAction func grayScaleButtonTapped(_ sender: Any) {
        doConversion(type: .grayScale)
    }
    
    @IBAction func invertColorsButtonTapped(_ sender: Any) {
        doConversion(type: .invertColors)
    }
    
    @IBAction func mirrorImageButtonTapped(_ sender: UIButton) {
        doConversion(type: .mirror)
    }
    
    @IBAction func rotateButtonTapped(_ sender: Any) {
        doConversion(type: .rotate)
    }
    
    func doConversion(type: ImageModificationType) {
        
        guard let oldImage = imageView.image else { return }

        let processingQueue = OperationQueue()
        
        let newItem = ImageItem(initialImage: oldImage)
        items.insert(newItem, at: 0)
        collectionView.reloadData()
        
        processingQueue.addOperation() {
            
            // Background thread
            
            let totalDelay = 5 + Int(arc4random_uniform(UInt32(30 - 5 + 1)))

            print("Delay \(totalDelay)")
            
            let progressStep:Float = 1 / Float(totalDelay)
            
            for _ in 0..<totalDelay {
                
                sleep(1)
                
                OperationQueue.main.addOperation() {
                    
                    // Main thread
                    newItem.progress += progressStep
                    self.collectionView.reloadData()
                }
            }
            
            // background thread
            // perform long operation
            let newImage = oldImage.convert(type: type)
            
            OperationQueue.main.addOperation() {
                // Main thread
                
                newItem.progress = 1.0 // to be sure
                newItem.image = newImage
                self.collectionView.reloadData()
            }
        }
    }
    
    @IBAction func tapImageView(_ sender: UITapGestureRecognizer) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = .photoLibrary
        present(controller, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = selectedPhoto
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - Collection DataSource

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionCell
        
        let item = items[indexPath.row]
        
        cell.cellImage.image = item.image
        cell.progressBar.isHidden = !item.isProgressBarVisible
        cell.progressBar.progress = item.progress

        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let image = items[indexPath.row].image
        
        let questionController = UIAlertController(title: "What u wanna do?", message: nil, preferredStyle: .alert)
        
        questionController.addAction(UIAlertAction(title: "Reuse Image", style: .default, handler: {
            
            (action:UIAlertAction!) -> Void in
            self.imageView.image = image
        }))
        
        questionController.addAction(UIAlertAction(title: "Save", style: .destructive, handler: {
            
            (action:UIAlertAction!) -> Void in
            UIImageWriteToSavedPhotosAlbum(image!, self, nil, nil)
            self.collectionView.reloadData()
            
        }))
        
        questionController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {
            
            (action:UIAlertAction!) -> Void in
            
            self.items.remove(at: indexPath.row)
            self.collectionView.reloadData()
            
        }))
        
        present(questionController, animated: true, completion: nil)
    }
}

// MARK: - extension UIImage

enum ImageModificationType {
    case mirror, invertColors, rotate, grayScale, halfMirror
}

extension UIImage {
    
    func convert(type: ImageModificationType) -> UIImage? {
        switch type {
        case .invertColors:
            return self.invertColors(cgResult: true)!
        case .mirror:
            return self.imageRotatedByDegrees(degrees: 0, flip: true)
        case .rotate:
            return self.imageRotatedByDegrees(degrees: 90, flip: false)
        case .grayScale:
            return self.convertImageToBW()
        case .halfMirror:
            return self.halfMirror()
            
        }
    }
    
    func halfMirror() -> UIImage? {
        guard let cgImage = cgImage else { return nil }
        guard let ctx = CGContext(data: nil,
                                  width: cgImage.width,
                                  height: cgImage.height,
                                  bitsPerComponent: cgImage.bitsPerComponent,
                                  bytesPerRow: cgImage.bytesPerRow,
                                  space: cgImage.colorSpace!,
                                  bitmapInfo: cgImage.bitmapInfo.rawValue) else { return nil }
        
        let flippedImage = UIImage(cgImage: cgImage)
        
        let cropRect = CGRect(x: 0, y: 0, width: flippedImage.size.width / 2, height: flippedImage.size.height)
        
        let theOtherHalf = flippedImage.cgImage?.cropping(to: cropRect)
        
        ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
        
        var transform = CGAffineTransform(translationX: flippedImage.size.width, y: 0.0)
        transform = transform.scaledBy(x: -1.0, y: 1.0)
        
        ctx.concatenate(transform)
        ctx.draw(theOtherHalf!, in: cropRect)
        
        let imageRef: CGImage = ctx.makeImage()!
        
        let finalImage = UIImage(cgImage: imageRef)

        return finalImage
    }
    
    func invertColors(cgResult: Bool) -> UIImage? {
        let coreImage = UIKit.CIImage(image: self)
        guard let filter = CIFilter(name: "CIColorInvert") else { return nil }
        filter.setValue(coreImage, forKey: kCIInputImageKey)
        guard let result = filter.value(forKey: kCIOutputImageKey) as? UIKit.CIImage else { return nil }
        if cgResult { // I've found that UIImage's that are based on CIImages don't work with a lot of calls properly
            return UIImage(cgImage: CIContext(options: nil).createCGImage(result, from: result.extent)!)
        }
        return UIImage(ciImage: result)
    }
    
    func imageRotatedByDegrees(degrees: CGFloat, flip: Bool) -> UIImage {
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat.pi
        }
        
        let rotatedSize: CGSize
        if degrees == 90 {
            rotatedSize = CGSize(width: size.height, height: size.width)
        } else if degrees == 0 {
            rotatedSize = size
        } else {
            fatalError()
        }

        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap?.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)
        
        //   // Rotate the image context
        bitmap?.rotate(by: degreesToRadians(degrees))
        
        // Now, draw the rotated/scaled image into the context
        var yFlip: CGFloat
        
        if(flip){
            yFlip = CGFloat(-1.0)
        } else {
            yFlip = CGFloat(1.0)
        }
        
        bitmap?.scaleBy(x: yFlip, y: -1.0)
        let rect = CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height)
        
        bitmap?.draw(cgImage!, in: rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func convertImageToBW() -> UIImage {
        let context = CIContext(options: nil)
        let currentFilter = CIFilter(name: "CIPhotoEffectNoir")!
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        let output = currentFilter.outputImage!
        let cgImage = context.createCGImage(output, from: output.extent)!
        let processedImage = UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        
        return processedImage
    }
}


