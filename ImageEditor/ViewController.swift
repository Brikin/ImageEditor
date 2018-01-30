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
        
        let processingQueue = OperationQueue()
        
        guard let oldImage = imageView.image else {return}
        
        let newItem = ImageItem(initialImage: oldImage)
        items.insert(newItem, at: 0)
        collectionView.reloadData()
        
        processingQueue.addOperation() {
            
          //  let totalDelay = 5 + Int(arc4random_uniform(UInt32(30 - 5 + 1)))
            let totalDelay = 1
            print("\(totalDelay)")
            
            let progressStep:Float = 1 / Float(totalDelay)
            
            for _ in 0..<totalDelay {
                
                sleep(1)
                
                OperationQueue.main.addOperation() {
                    // Main thread
                    
                    newItem.progress += progressStep
                    self.updateCellForItem(item: newItem)
                }
            }
            
            // background thread
            // long operation
            let newImage = oldImage.convert(type: type)
            
            OperationQueue.main.addOperation() {
                // Main thread
                newItem.progress = 1.0 // to be sure
                newItem.image = newImage
                self.updateCellForItem(item: newItem)
            }
        }
    }
    
    func updateCellForItem(item: ImageItem) {
        
        guard let index = items.index(where: { $0 === item }) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        if let cell = self.collectionView.cellForItem(at: indexPath) as? CollectionCell{
            cell.cellImage.image = item.image
            cell.progressBar.isHidden = !item.isProgressBarVisible
            cell.progressBar.progress = item.progress
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

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionCell
        
        let imageItem = items[indexPath.row]
        updateCellForItem(item: imageItem)
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

enum ImageModificationType {
    case mirror, invertColors, rotate, grayScale, halfMirror
}

extension UIImage {
    
    func convert(type: ImageModificationType) -> UIImage {
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
    
    func halfMirror() -> UIImage {
        
        var flippedOrientation: UIImageOrientation = .downMirrored
       
        switch imageOrientation {
        case .up:
            break
        case .down:
            flippedOrientation = .downMirrored
        case .left:
            break
        case .right:
            break
        case .upMirrored:
            break
        case .downMirrored:
            break
        case .leftMirrored:
            break
        case .rightMirrored:
            break
        }
        
        var flippedImage = UIImage(cgImage: cgImage!, scale: 1.0, orientation: flippedOrientation)
        
        var inImage = cgImage!
    
        var ctx = CGContext(data: nil,
                                width: inImage.width,
                                height: inImage.height,
                                bitsPerComponent: inImage.bitsPerComponent,
                                bytesPerRow: inImage.bytesPerRow,
                                space: inImage.colorSpace!,
                                bitmapInfo: inImage.bitmapInfo.rawValue)
        
        var cropRect = CGRect(x: flippedImage.size.width / 2, y: 0, width: flippedImage.size.width / 2, height: flippedImage.size.height)
        
        var theOtherHalf = flippedImage.cgImage?.cropping(to: cropRect)
        
        ctx?.draw(inImage, in: CGRect(x: 0, y: 0, width: inImage.width, height: inImage.height))
        
        var transform = CGAffineTransform(translationX: flippedImage.size.width, y: 0.0)
        transform = transform.scaledBy(x: -1.0, y: 1.0)
        
        ctx?.concatenate(transform)
        ctx?.draw(theOtherHalf!, in: cropRect)
        
        var imageRef: CGImage = ctx!.makeImage()!
        
        var finalImage = UIImage(cgImage: imageRef)


        return finalImage
        
        
       
   
//        let cropRect = CGRect(x: 0, y: 0, width: image.size.width / 2, height: image.size.height)
//        UIGraphicsBeginImageContextWithOptions(cropRect.size, false, image.scale)
//        let origin = CGPoint(x: cropRect.origin.x * CGFloat(-1), y: cropRect.origin.y * CGFloat(-1))
//        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width / 2, height: image.size.height))
//        let result = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext();
//
//        return result!
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
        let radiansToDegrees: (CGFloat) -> CGFloat = {
            return $0 * (180.0 / CGFloat.pi)
        }
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat.pi
        }
        
        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: .zero, size: size))
        let t = CGAffineTransform(rotationAngle: degreesToRadians(degrees));
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
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















